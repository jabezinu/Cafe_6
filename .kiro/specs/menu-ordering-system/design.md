# Design Document - Menu & Ordering System

## Overview

The Menu & Ordering System provides a comprehensive e-commerce experience for cafe customers, enabling menu browsing, cart management, order placement, and order tracking. The system integrates with the authentication system and provides real-time updates for optimal user experience.

## Architecture

### Backend Architecture (Rails API)
- **Menu Items Controller**: Manages menu display and filtering
- **Cart Controller**: Handles cart operations and persistence
- **Orders Controller**: Manages order creation and tracking
- **Menu Item Model**: Product catalog with categories and pricing
- **Cart Model**: Session-based cart with item relationships
- **Order Model**: Order records with line items and status tracking

### Frontend Architecture (React)
- **Menu Components**: Item display, filtering, and search functionality
- **Cart Context**: Global cart state management with persistence
- **Order Components**: Checkout flow and order history display
- **Product Components**: Item details and customization options
- **State Management**: Zustand for cart and order state

## Components and Interfaces

### Backend API Endpoints

#### Menu Endpoints
```
GET /api/menu-items
GET /api/menu-items/:id
GET /api/categories
GET /api/menu-items/search?q=:query
GET /api/menu-items/category/:category_id
```

#### Cart Endpoints
```
GET /api/cart
POST /api/cart/items
PUT /api/cart/items/:id
DELETE /api/cart/items/:id
DELETE /api/cart/clear
```

#### Order Endpoints
```
POST /api/orders
GET /api/orders
GET /api/orders/:id
GET /api/orders/:id/status
```

### Frontend Components

#### Menu Components
- `MenuGrid`: Displays menu items in a responsive grid
- `MenuItem`: Individual menu item with image, details, and add to cart
- `CategoryFilter`: Filter menu by categories
- `MenuSearch`: Search functionality for menu items
- `ItemModal`: Detailed view with customization options

#### Cart Components
- `CartProvider`: Context provider for cart state
- `CartIcon`: Header cart icon with item count
- `CartSidebar`: Slide-out cart with item management
- `CartItem`: Individual cart item with quantity controls
- `CartSummary`: Price breakdown and totals

#### Order Components
- `CheckoutForm`: Order confirmation and placement
- `OrderHistory`: List of customer's past orders
- `OrderDetails`: Detailed view of specific order
- `OrderStatus`: Real-time order status updates

## Data Models

### Menu Item Model (Backend)
```ruby
class MenuItem < ApplicationRecord
  belongs_to :category
  has_many :cart_items
  has_many :order_items
  has_one_attached :image
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 500 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :category_id, presence: true
  
  scope :available, -> { where(available: true) }
  scope :by_category, ->(category) { where(category: category) }
  
  # Attributes: name, description, price, category_id, image_url, available, created_at, updated_at
end
```

### Cart Model (Backend)
```ruby
class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :menu_items, through: :cart_items
  
  def total_price
    cart_items.sum { |item| item.quantity * item.menu_item.price }
  end
  
  def total_items
    cart_items.sum(:quantity)
  end
end

class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :menu_item
  
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :menu_item_id, uniqueness: { scope: :cart_id }
end
```

### Order Model (Backend)
```ruby
class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :menu_items, through: :order_items
  
  validates :status, presence: true, inclusion: { in: %w[pending confirmed preparing ready delivered cancelled] }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  
  before_create :generate_order_number
  
  # Attributes: order_number, user_id, status, total_amount, notes, created_at, updated_at
end
```

### Frontend State Models
```javascript
interface MenuItem {
  id: number;
  name: string;
  description: string;
  price: number;
  category: string;
  imageUrl: string;
  available: boolean;
}

interface CartItem {
  id: number;
  menuItem: MenuItem;
  quantity: number;
  customizations?: string[];
  specialInstructions?: string;
}

interface CartState {
  items: CartItem[];
  totalItems: number;
  totalPrice: number;
  isLoading: boolean;
}

interface Order {
  id: number;
  orderNumber: string;
  status: string;
  totalAmount: number;
  items: OrderItem[];
  createdAt: string;
}
```

## Error Handling

### Backend Error Responses
- **400 Bad Request**: Invalid cart operations or order data
- **404 Not Found**: Menu item or order not found
- **422 Unprocessable Entity**: Validation errors for orders
- **409 Conflict**: Cart conflicts or inventory issues

### Frontend Error Handling
- Network error handling with retry mechanisms
- Cart synchronization error recovery
- Order placement failure handling
- Inventory unavailability notifications

### Error Response Format
```json
{
  "error": "Order creation failed",
  "details": {
    "cart": ["cannot be empty"],
    "total_amount": ["must be greater than 0"]
  }
}
```

## Testing Strategy

### Backend Testing (RSpec)
- **Model Tests**: Menu item validations, cart calculations, order state transitions
- **Controller Tests**: API endpoints, authentication requirements, error handling
- **Integration Tests**: Complete ordering flow from cart to order confirmation
- **Service Tests**: Cart management, order processing, and inventory checks

### Frontend Testing (Jest/React Testing Library)
- **Component Tests**: Menu display, cart operations, order placement
- **State Tests**: Cart state management, persistence, and synchronization
- **Integration Tests**: Complete user flows from menu browsing to order completion
- **API Tests**: Mock API responses and error scenarios

### Test Coverage Goals
- Backend: 85%+ coverage for ordering logic
- Frontend: 80%+ coverage for cart and order components
- End-to-end: Critical user journeys (browse → add to cart → checkout → order)

## Performance Considerations

### Backend Optimization
- Database indexing on frequently queried fields (category_id, user_id)
- Eager loading for menu items with categories and images
- Caching for menu data with cache invalidation
- Pagination for large menu catalogs and order history

### Frontend Optimization
- Image lazy loading for menu items
- Virtual scrolling for large menu lists
- Cart state persistence in localStorage
- Debounced search functionality
- Optimistic UI updates for cart operations

### Caching Strategy
- Menu items cached for 15 minutes
- Cart data cached in browser storage
- Order history cached with smart invalidation
- Image caching through Cloudinary CDN