module Api
  class NotificationsController < BaseController
    before_action :authenticate_user!
    before_action :find_notification, only: [:answer_request_employee]
    respond_to :json

    PAGE = 1
    PER_PAGE = 5

    api :GET,
    "/api/notifications",
    "Get current_user notifications"
    example %q[{
      [{
        "message": "I am a notification",
        "status": "pending",
        "kind": "client_points",
        "from_employee_id": "11",
        "from_user_id": "21",
        "to_user_id": "32"
      },{
        "message": "I am a notification 2",
        "status": "pending",
        "kind": "client_points",
        "from_employee_id": "1",
        "from_user_id": "2",
        "to_user_id": "3"
      }],
    }]
    def index
      notifications_list = Notification.where(to_user_id: current_user.id).order(created_at: :desc)
      notifications = notifications_list.page(params[:page] || PAGE).per(params[:per_page] || PER_PAGE)
      render "api/notifications/notifications",
              locals: { notifications:  notifications, total_count: notifications.total_count }
    end

    api :PUT,
    "/notifications/:id/:answer_request_employee",
    "approved/declined a request to be employee"
    param :id, Integer, required: true
    example %q{
      "employee":{
        "user": {
          "email": "cashier@example.com",
          "nickname": "chasier",
          "name": "Chasier",
          "national_id": "1234567892",
        },
        "role": "cashier",
        "active": true
      },
      "notification": {
        "message": "I am a notification 2",
        "status": "pending",
        "kind": "client_points",
        "from_employee_id": "1",
        "from_user_id": "2",
        "to_user_id": "3"
      }
    }

    def answer_request_employee
      status = params[:status]
      unless ["approved", "decline"].include?(status)
        render json: { status: ["is invalid"] }, status: :unprocessable_entity
        return
      end

      employee = nil
      outcome = :answered
      begin
        Notification.transaction do
          @notification.lock!
          unless @notification.kind == "request_employee" && @notification.status == "pending"
            outcome = :already_answered
            raise ActiveRecord::Rollback
          end

          if status == "approved"
            partner = Employee.lock.find_by(id: @notification.from_employee_id)
            unless partner&.role == "partner" && partner.status == "approved"
              outcome = :partner_unapproved
              raise ActiveRecord::Rollback
            end

            recipient = User.lock.find(@notification.to_user_id)
            if Employee.exists?(user: recipient, company: partner.company)
              outcome = :already_member
              raise ActiveRecord::Rollback
            end

            employee = create_employe(partner, recipient)
            employee.save!
          end

          @notification.update!(status: status)
          notify_company!(employee)
        end
      rescue ActiveRecord::RecordInvalid => error
        render json: error.record.errors, status: :unprocessable_entity
        return
      end

      if outcome == :already_answered
        render json: { error: "This request has already been answered" }, status: :conflict
      elsif outcome == :partner_unapproved
        render json: { error: "The requesting partner is no longer approved" }, status: :forbidden
      elsif outcome == :already_member
        render json: { error: "User already has a membership in this company" }, status: :conflict
      elsif employee
        render json: { employee: employee, notification: @notification }, status: :created
      else
        render json: { notification: @notification }, status: :created
      end
    end

    api :POST,
    "/notifications/:id/:answer_request_employee",
    "approved/declined a request to be employee"
    param :id, Integer, required: true
    example %q{
      "employee":{
        "user": {
          "email": "cashier@example.com",
          "nickname": "chasier",
          "name": "Chasier",
          "national_id": "1234567892",
        },
        "role": "cashier",
        "active": true
      },
      "notification": {
        "message": "I am a notification 2",
        "status": "pending",
        "kind": "client_points",
        "from_employee_id": "1",
        "from_user_id": "2",
        "to_user_id": "3"
      }
    }

    def read_pending_notifications
      notifications = Notification.where(to_user_id: current_user.id, status: "pending")
                  .where.not(kind: "request_employee")
      total = notifications.count
      notifications.update_all(:status => "read")
      render json: {status: :ok, total: total}, status: :ok
    end


    private

    def find_notification
      @notification = Notification.where(to_user_id: current_user.id).find(params[:id])
    end

    def create_employe(partner, recipient)
      employee = Employee.new
      employee.company = partner.company
      employee.role = 'cashier';
      employee.status = params[:status];
      employee.user = recipient
      employee
    end

    def notify_company!(employee)
      UtilService.new( @notification.from_user,
                        current_user,
                        { status: params[:status],
                          employee: employee
                        }
                      ).notify_company_request_employee
    end
  end
end
