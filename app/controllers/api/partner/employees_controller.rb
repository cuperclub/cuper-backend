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
        employees = current_user.company.employees
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
      "/partner/employees/:id",
      "Edit a employee"
      param :id, Integer, required: true
      example %q{
        "employee":{
          "active": true
        }
      }

      def update
        employee = current_user.company.employees.find(params[:id])
        if employee.update(employee_params)
          render :employee,
                  status: :accepted,
                  locals: { employee: employee }
        else
          render json: employee.errors,
                status: :unprocessable_entity
        end
      end

      private

      def employee_params
        params.require(:employee).permit(
          :active
        )
      end
    end
  end
end
