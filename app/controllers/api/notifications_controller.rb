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
      if @notification.kind == "request_employee" && @notification.status == "pending"
        @notification.status = params[:status]
        @notification.save
        if params[:status] === "approved"
          employee = create_employe
          if employee.save
            notify_company!(employee)
            render json: { employee: employee, notification: @notification },
                    status: :created
          else
            render json: employee.errors,
                  status: :unprocessable_entity
          end
        else
          notify_company!(nil)
          render json: { notification: @notification },
                status: :created
        end
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
      @notification = Notification.find(params[:id])
    end

    def create_employe
      employee = Employee.new
      employee.company = @notification.from_employee.company;
      employee.role = 'cashier';
      employee.status = params[:status];
      employee.user = @notification.to_user;
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
