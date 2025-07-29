class Api::CommentsController < ApplicationController
  before_action :authenticate_user, except: [:create]
  
  # Create a new comment
  def create
    name = params[:name]
    phone = params[:phone]
    comment = params[:comment]
    anonymous = !!params[:anonymous]

    # Validation: if not anonymous, name and phone are required
    unless anonymous
      if name.blank? || phone.blank?
        render json: { 
          success: false, 
          message: 'Name and phone are required if not anonymous.' 
        }, status: :bad_request
        return
      end
    else
      name = ''
      phone = ''
    end

    new_comment = Comment.new(
      name: name,
      phone: phone,
      comment: comment,
      anonymous: anonymous
    )

    if new_comment.save
      render json: { 
        success: true, 
        message: 'Comment submitted successfully', 
        comment: new_comment 
      }, status: :created
    else
      render json: { 
        success: false, 
        message: 'Failed to submit comment', 
        error: new_comment.errors.full_messages.join(', ')
      }, status: :internal_server_error
    end
  rescue => error
    render json: { 
      success: false, 
      message: 'Failed to submit comment', 
      error: error.message 
    }, status: :internal_server_error
  end

  # Get all comments
  def index
    comments = Comment.order(created_at: :desc)
    render json: { success: true, comments: comments }, status: :ok
  rescue => error
    render json: { 
      success: false, 
      message: 'Failed to fetch comments', 
      error: error.message 
    }, status: :internal_server_error
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