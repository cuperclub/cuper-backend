module Api
  module Partner
    class EmployeesController < BaseController
      before_action :authenticate_user!

      api :GET,
          "/partner/employees",
          "Get all employees"
      example %q{
        "employees":[{
          "user": {
            "email": "cashier@example.com",
            "nickname": "chasier",
            "name": "Chasier",
            "national_id": "1234567892",
          },
          "role": "cashier",
          "active": true
        }]
      }

      def index
        employees = current_user.company
                                .employees
                                .where.not(user: current_user)
        render :employees,
              status: :created,
              locals: { employees: employees }
      end

      api :GET,
          "/partner/employees/:id",
          "Get a employee"
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
        }
      }

      def show
        employee = current_user.company.employees.find(params[:id])
        render :employee,
                status: :accepted,
                locals: { employee: employee }
      end

      api :PUT,
      "/partner/employees/:id/update_state",
      "Edit a employee"
      param :id, Integer, required: true
      example %q{
        "employee":{
          "status": "disabled",
          "feedback": "employee in vacations"
        }
      }

      def update_state
        employee = current_user.company.employees.find(params[:id])
        if employee.update(employee_access_params)
          render :employee,
                  status: :accepted,
                  locals: { employee: employee }
        else
          render json: employee.errors,
                status: :unprocessable_entity
        end
      end

      private

      def employee_access_params
        params.require(:employee).permit(
          :status,
          :feedback
        )
      end
    end
  end
end
