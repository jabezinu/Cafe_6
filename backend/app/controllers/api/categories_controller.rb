class Api::CategoriesController < ApplicationController
  before_action :authenticate_user, except: [:index]
  
  # Create a new category
  def create
    category = Category.new(name: params[:name])
    
    if category.save
      render json: category, status: :created
    else
      render json: { errors: category.errors }, status: :unprocessable_entity
    end
  end

  # Get all categories
  def index
    categories = Category.all
    render json: categories, status: :ok
  end

  # Update a category by ID
  def update
    category = Category.find_by(id: params[:id])
    
    if category.nil?
      render json: { message: 'Category not found' }, status: :not_found
      return
    end

    if category.update(name: params[:name])
      render json: category, status: :ok
    else
      render json: { errors: category.errors }, status: :unprocessable_entity
    end
  end

  # Delete a category by ID
  def destroy
    category = Category.find_by(id: params[:id])
    
    if category.nil?
      render json: { message: 'Category not found' }, status: :not_found
      return
    end

    # Delete all menu items under this category first
    Menu.where(category: category).destroy_all
    category.destroy
    
    render json: { message: 'Category and related menu items deleted' }, status: :ok
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