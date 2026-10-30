class PointMovement < ApplicationRecord
  belongs_to :user
  belongs_to :transaction_input, optional: true
  belongs_to :transaction_output, optional: true
  belongs_to :reversal_of, class_name: "PointMovement", optional: true
  has_one :reversal, class_name: "PointMovement", foreign_key: :reversal_of_id

  TRANSACTION_KINDS = %w[accrual redemption].freeze
  MANUAL_KINDS = %w[expiry adjustment reversal opening_balance reconciliation].freeze
  KINDS = (TRANSACTION_KINDS + MANUAL_KINDS).freeze

  validates :points, numericality: { only_integer: true }
  validates :kind, inclusion: { in: KINDS }
  validates :idempotency_key, length: { maximum: 255 }, allow_nil: true
  validates :idempotency_key, uniqueness: { scope: :user_id }, allow_nil: true
  validates :reference_key, length: { maximum: 255 }, allow_nil: true
  validates :reference_key, uniqueness: { scope: :user_id }, allow_nil: true
  validates :reason, presence: true, if: -> { MANUAL_KINDS.include?(kind) }
  validates :reference_key, presence: true, if: -> { MANUAL_KINDS.include?(kind) }
  validates :reversal_of_id, uniqueness: true, allow_nil: true
  validate :one_source_matches_user
  validate :points_match_kind
  validate :reversal_matches_source
  before_validation :prevent_mutation, on: :update
  before_destroy :prevent_mutation

  def self.adjust!(user:, points:, reason:, reference_key:)
    post!(user: user, points: points, kind: "adjustment", reason: reason, reference_key: reference_key)
  end

  def self.expire!(user:, points:, reason:, reference_key:)
    raise ArgumentError, "points must be a positive integer" unless points.is_a?(Integer) && points.positive?

    post!(user: user, points: -points, kind: "expiry", reason: reason, reference_key: reference_key)
  end

  def self.opening_balance!(user:, points:, reason:, reference_key:)
    raise ArgumentError, "points must be a positive integer" unless points.is_a?(Integer) && points.positive?

    post!(user: user, points: points, kind: "opening_balance", reason: reason, reference_key: reference_key)
  end

  def self.reverse!(movement:, reason:, reference_key:)
    raise ArgumentError, "movement must be a persisted, non-reversal event" unless movement.persisted? && movement.kind != "reversal" && movement.points.to_i.nonzero?

    post!(
      user: movement.user,
      points: -movement.points,
      kind: "reversal",
      reason: reason,
      reference_key: reference_key,
      reversal_of: movement
    )
  end

  def self.reconcile!(user:)
    result = nil
    transaction do
      user.with_lock do
        ledger_total = where(user_id: user.id).sum(:points).to_i
        difference = (user.points || 0) - ledger_total
        if difference.zero?
          result = [nil, false]
        else
          result = post!(
            user: user,
            points: difference,
            kind: "reconciliation",
            reason: "Reconcile ledger total to the existing balance projection",
            reference_key: "reconciliation:#{user.id}:#{user.points}:#{ledger_total}",
            update_balance: false
          )
        end
      end
    end
    result
  end

  def self.reconciliation_mismatches
    User.left_outer_joins(:point_movements)
      .group("users.id", "users.points")
      .having("COALESCE(SUM(point_movements.points), 0) <> COALESCE(users.points, 0)")
      .pluck("users.id", Arel.sql("COALESCE(users.points, 0)"), Arel.sql("COALESCE(SUM(point_movements.points), 0)"))
      .map { |user_id, balance, ledger_total| [user_id, balance.to_i, ledger_total.to_i] }
  end

  def self.post!(user:, points:, kind:, reason:, reference_key:, reversal_of: nil, update_balance: true)
    raise ArgumentError, "points must be an integer" unless points.is_a?(Integer)

    result = nil
    transaction do
      user.with_lock do
        existing = find_by(user_id: user.id, reference_key: reference_key) if reference_key.present?
        if existing
          if existing.kind == kind && existing.points == points && existing.reason == reason && existing.reversal_of_id == reversal_of&.id
            result = [existing, true]
          else
            existing.errors.add(:base, :reference_key_reused)
            raise ActiveRecord::RecordInvalid, existing
          end
        else
          movement = new(
            user: user,
            points: points,
            kind: kind,
            reason: reason,
            reference_key: reference_key,
            reversal_of: reversal_of
          )
          balance = (user.points || 0) + points
          unless points.between?(-TransactionInput::MAX_SAFE_POINT_VALUE, TransactionInput::MAX_SAFE_POINT_VALUE)
            movement.errors.add(:points, "is outside the exact integer range")
            raise ActiveRecord::RecordInvalid, movement
          end
          if update_balance && !balance.between?(-TransactionInput::MAX_SAFE_POINT_VALUE, TransactionInput::MAX_SAFE_POINT_VALUE)
            movement.errors.add(:points, "would move the balance outside the exact integer range")
            raise ActiveRecord::RecordInvalid, movement
          end
          if update_balance && balance.negative?
            movement.errors.add(:points, "would make the balance negative")
            raise ActiveRecord::RecordInvalid, movement
          end
          if kind == "opening_balance" && ((user.points || 0) != 0 || exists?(user_id: user.id))
            movement.errors.add(:base, "opening balance requires a new account with no movements")
            raise ActiveRecord::RecordInvalid, movement
          end

          movement.save!
          user.update!(points: balance) if update_balance
          result = [movement, false]
        end
      end
    end
    result
  end

  def readonly?
    persisted? || super
  end

  private

  def one_source_matches_user
    sources = [transaction_input, transaction_output].compact
    source_valid = if TRANSACTION_KINDS.include?(kind)
      sources.one? && sources.first.user_id == user_id && source_matches_kind_and_points(sources.first)
    else
      sources.empty?
    end
    return if source_valid

    errors.add(:base, :invalid)
  end

  def points_match_kind
    return if points.nil?
    return if kind == "accrual" && points.to_i >= 0
    return if %w[redemption expiry].include?(kind) && points.to_i < 0
    return if %w[adjustment reversal reconciliation].include?(kind) && points.to_i.nonzero?
    return if kind == "opening_balance" && points.to_i.positive?

    errors.add(:points, :invalid)
  end

  def source_matches_kind_and_points(source)
    return kind == "accrual" && source == transaction_input && points == transaction_input.points if kind == "accrual"
    return kind == "redemption" && source == transaction_output && points == -transaction_output.points if kind == "redemption"

    false
  end

  def reversal_matches_source
    if kind == "reversal"
      return if reversal_of && reversal_of.user_id == user_id && reversal_of.kind != "reversal" && points == -reversal_of.points
    elsif reversal_of_id.nil?
      return
    end

    errors.add(:reversal_of, :invalid)
  end

  def prevent_mutation
    raise ActiveRecord::ReadOnlyRecord
  end
end
