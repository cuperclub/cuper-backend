class UtilService
  def initialize(client, current_user = nil, meta = "")
    @client = client
    @current_user = current_user
    @meta = meta
  end

  def app_settings
    return AppSetting.last
  end

  def assign_promo_points
    app = app_settings
    if app && app.points_by_register > 0
      binding.pry
      transaction_input = TransactionInput.new(
        user: @client,
        employee_id: app.main_employee_id,
        points: app.points_by_register
      )
      transaction_input.save
      notify_assign_points!
    end
  end

  def notify_employee_request
    notification = Notification.new
    company = user_company
    employee = user_employee
    notification.message = "La empresa: #{company.business_name} quiere registrarte como empleado"
    notification.kind = "request_employee"
    notification.from_employee_id = employee.id
    notification.from_user_id = @current_user.id
    notification.to_user_id = @client.id
    notification
  end

  def notify_company_change_status
    notification = Notification.new
    company = @meta[:company]
    status = I18n.t("models.employee.status.#{@meta[:status]}")
    emoji = I18n.t("models.employee.status_emoji.#{@meta[:status]}")
    notification.message = "Tu empresa: #{company.business_name} ha sido #{status} #{emoji}"
    notification.kind = "company_status"
    notification.from_employee_id = app_settings.main_employee_id
    notification.from_user_id = @current_user.id
    notification.to_user_id = @client.id
    notification.save
  end

  def notify_company_request_employee
    notification = Notification.new
    company = @meta[:company]
    status = I18n.t("models.employee.status.#{@meta[:status]}")
    emoji = I18n.t("models.employee.status_emoji.#{@meta[:status]}")
    notification.message = "#{@current_user.name}: Ha #{status} tu solicitud de empleado #{emoji}"
    notification.kind = "answer_request_employee"
    notification.from_employee_id = @meta[:employee].nil? ? nil : @meta[:employee].id
    notification.from_user_id = @current_user.id
    notification.to_user_id = @client.id
    notification.save
  end

  def notify_client_assign_points
    notification = Notification.new
    company = @meta[:company]
    employee = @meta[:employee]
    points = @meta[:points]
    notification.message = "#{company.business_name} te ha asignado: #{points} Pts. por consumo"
    notification.kind = "assign_points"
    notification.from_employee_id = employee.id
    notification.from_user_id = @current_user.id
    notification.to_user_id = @client.id
    notification.save
  end

  def notify_client_assign_promotion
    notification = Notification.new
    company = @meta[:company]
    employee = @meta[:employee]
    promotion = @meta[:promotion]
    notification.message = "Has canjeado #{promotion.title} en: #{company.business_name} por #{promotion.points_required} Pts"
    notification.kind = "assign_points"
    notification.from_employee_id = employee.id
    notification.from_user_id = @current_user.id
    notification.to_user_id = @client.id
    notification.save
  end

  private

  def notify_assign_points!
    notification = Notification.new
    notification.message = "Cuper Club te ha recompensado con: #{app_settings.points_by_register} Pts. por registrarte 🎉🎉"
    notification.kind = "inital_points"
    notification.from_employee_id = app_settings.main_employee_id
    notification.from_user_id = app_settings.main_employee_id
    notification.to_user_id = @client.id
    notification.save
  end

  def user_company
    Company.find(@current_user.current_view_company_id)
  end

  def user_employee
    company = user_company
    Employee.find_by_company_id(company.id)
  end
end
