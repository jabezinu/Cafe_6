class Api::EmployeesController < ApplicationController
  before_action :authenticate_user
  
  # Create a new employee
  def create
    image_url = params[:image]
    
    # Handle file upload with Cloudinary
    if params[:image].present? && params[:image].respond_to?(:tempfile)
      uploaded_url = ImageUploadService.upload(params[:image])
      image_url = uploaded_url if uploaded_url
    end

    employee_params = {
      name: params[:name],
      phone: params[:phone],
      image: image_url,
      position: params[:position],
      salary: params[:salary],
      date_hired: params[:date_hired] || Time.current,
      description: params[:description],
      working_hour: params[:working_hour],
      status: params[:status] || 'active',
      reason_for_leaving: params[:reason_for_leaving] || ''
    }

    # Ensure tableAssigned is only set if position is waiter
    if params[:position] == 'waiter'
      employee_params[:table_assigned] = params[:table_assigned]
    end

    employee = Employee.new(employee_params)

    if employee.save
      render json: employee, status: :created
    else
      render json: { errors: employee.errors }, status: :unprocessable_entity
    end
  end

  # Get all employees
  def index
    employees = Employee.all
    render json: employees
  end

  # Get a single employee by ID
  def show
    employee = Employee.find_by(id: params[:id])
    
    if employee.nil?
      render json: { message: 'Employee not found' }, status: :not_found
      return
    end

    render json: employee
  end

  # Update an employee
  def update
    employee = Employee.find_by(id: params[:id])
    
    if employee.nil?
      render json: { message: 'Employee not found' }, status: :not_found
      return
    end

    image_url = params[:image]
    
    # Handle file upload with Cloudinary
    if params[:image].present? && params[:image].respond_to?(:tempfile)
      uploaded_url = ImageUploadService.upload(params[:image])
      image_url = uploaded_url if uploaded_url
    end

    update_params = {
      name: params[:name],
      phone: params[:phone],
      image: image_url,
      position: params[:position],
      salary: params[:salary],
      description: params[:description],
      working_hour: params[:working_hour],
      status: params[:status],
      reason_for_leaving: params[:reason_for_leaving]
    }

    # Ensure tableAssigned is only set if position is waiter
    if params[:position] == 'waiter'
      update_params[:table_assigned] = params[:table_assigned]
    else
      update_params[:table_assigned] = nil
    end

    if employee.update(update_params.compact)
      render json: employee
    else
      render json: { errors: employee.errors }, status: :unprocessable_entity
    end
  end

  # Delete an employee
  def destroy
    employee = Employee.find_by(id: params[:id])
    
    if employee.nil?
      render json: { message: 'Employee not found' }, status: :not_found
      return
    end

    employee.destroy
    render json: { message: 'Employee deleted' }
  end

  private



  # Authentication middleware
  def authenticate_user
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token.blank?
      render json: { message: 'Access token required.' }, status: :unauthorized
      return
    end

    begin
      decoded_token = JWT.decode(token, ENV['JWT_SECRET'] || 'your_jwt_secret', true, { algorithm: 'HS256' })
      @current_user_id = decoded_token[0]['id']
    rescue JWT::DecodeError
      render json: { message: 'Invalid token.' }, status: :unauthorized
    end
  end
end