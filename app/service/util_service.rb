class UtilService
  def initialize(client)
    @client = client
  end

  def app_settings
    return AppSetting.last
  end

  def assign_promo_points
    app = app_settings
    if app && app.points_by_register > 0
      transaction_input = TransactionInput.new(
        user: @client,
        employee_id: app.main_employee_id,
        points: app.points_by_register
      )
      transaction_input.save
    end
  end
end
