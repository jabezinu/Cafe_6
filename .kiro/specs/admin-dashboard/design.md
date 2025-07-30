# Design Document - Admin Dashboard & Analytics System

## Overview

The Admin Dashboard & Analytics System provides comprehensive administrative tools for cafe management, including order processing, menu management, user administration, and business analytics. The system features role-based access control and real-time data visualization for effective business operations.

## Architecture

### Backend Architecture (Rails API)
- **Admin Authentication Controller**: Secure admin login and session management
- **Admin Orders Controller**: Order management and status updates
- **Admin Menu Controller**: Menu item CRUD operations with image handling
- **Admin Users Controller**: Customer account management
- **Analytics Controller**: Business metrics and reporting
- **Admin Model**: Admin user accounts with role-based permissions

### Frontend Architecture (React)
- **Admin Layout**: Consistent dashboard layout with navigation
- **Dashboard Components**: Overview widgets and key metrics
- **Management Components**: CRUD interfaces for orders, menu, and users
- **Analytics Components**: Charts, graphs, and reporting tools
- **State Management**: Zustand for admin application state

## Components and Interfaces

### Backend API Endpoints

#### Admin Authentication
```
POST /api/admin/auth/login
DELETE /api/admin/auth/logout
GET /api/admin/auth/verify
```

#### Order Management
```
GET /api/admin/orders
GET /api/admin/orders/:id
PUT /api/admin/orders/:id/status
GET /api/admin/orders/stats
GET /api/admin/orders/search?q=:query
```

#### Menu Management
```
GET /api/admin/menu-items
POST /api/admin/menu-items
PUT /api/admin/menu-items/:id
DELETE /api/admin/menu-items/:id
POST /api/admin/menu-items/:id/image
GET /api/admin/categories
POST /api/admin/categories
```

#### User Management
```
GET /api/admin/users
GET /api/admin/users/:id
PUT /api/admin/users/:id/status
GET /api/admin/users/search?q=:query
```

#### Analytics
```
GET /api/admin/analytics/dashboard
GET /api/admin/analytics/sales?period=:period
GET /api/admin/analytics/popular-items
GET /api/admin/analytics/reports
```

### Frontend Components

#### Layout Components
- `AdminLayout`: Main dashboard layout with sidebar navigation
- `AdminHeader`: Top navigation with user info and logout
- `AdminSidebar`: Navigation menu with active state management
- `AdminBreadcrumb`: Page navigation breadcrumbs

#### Dashboard Components
- `DashboardOverview`: Key metrics and quick stats
- `RecentOrders`: Latest orders with quick actions
- `SalesChart`: Revenue visualization over time
- `PopularItems`: Top-selling menu items widget

#### Management Components
- `OrdersTable`: Sortable, filterable orders list
- `OrderDetails`: Detailed order view with status updates
- `MenuItemForm`: Create/edit menu items with image upload
- `MenuItemsList`: Manage all menu items with bulk actions
- `UsersTable`: Customer management interface
- `UserProfile`: Detailed customer information view

#### Analytics Components
- `SalesAnalytics`: Revenue charts and trends
- `ItemAnalytics`: Menu item performance metrics
- `ReportsGenerator`: Custom report creation tool
- `ExportTools`: Data export functionality

## Data Models

### Admin Model (Backend)
```ruby
class Admin < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :role, presence: true, inclusion: { in: %w[super_admin admin manager] }
  
  enum role: { super_admin: 0, admin: 1, manager: 2 }
  
  # Attributes: email, full_name, role, password_digest, last_login_at, created_at, updated_at
end
```

### Analytics Models (Backend)
```ruby
class DailySale < ApplicationRecord
  validates :date, presence: true, uniqueness: true
  validates :total_revenue, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :order_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Attributes: date, total_revenue, order_count, average_order_value
end

class ItemSale < ApplicationRecord
  belongs_to :menu_item
  
  validates :date, presence: true
  validates :quantity_sold, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :revenue, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Attributes: menu_item_id, date, quantity_sold, revenue
end
```

### Frontend State Models
```javascript
interface AdminUser {
  id: number;
  email: string;
  fullName: string;
  role: 'super_admin' | 'admin' | 'manager';
  lastLoginAt: string;
}

interface DashboardStats {
  todayRevenue: number;
  todayOrders: number;
  pendingOrders: number;
  totalCustomers: number;
  popularItems: PopularItem[];
  recentOrders: Order[];
}

interface SalesData {
  date: string;
  revenue: number;
  orderCount: number;
  averageOrderValue: number;
}

interface AdminState {
  admin: AdminUser | null;
  isAuthenticated: boolean;
  dashboardStats: DashboardStats | null;
  isLoading: boolean;
}
```

## Error Handling

### Backend Error Responses
- **401 Unauthorized**: Invalid admin credentials or insufficient permissions
- **403 Forbidden**: Role-based access denied
- **404 Not Found**: Resource not found (orders, menu items, users)
- **422 Unprocessable Entity**: Validation errors for admin operations

### Frontend Error Handling
- Permission-based error handling with appropriate messaging
- Network error recovery with retry mechanisms
- Form validation with real-time feedback
- Bulk operation error handling with partial success reporting

### Error Response Format
```json
{
  "error": "Access denied",
  "message": "Insufficient permissions for this operation",
  "required_role": "admin"
}
```

## Testing Strategy

### Backend Testing (RSpec)
- **Model Tests**: Admin validations, role permissions, analytics calculations
- **Controller Tests**: Admin endpoints, authorization, and data filtering
- **Integration Tests**: Complete admin workflows and permission checks
- **Analytics Tests**: Data aggregation accuracy and performance

### Frontend Testing (Jest/React Testing Library)
- **Component Tests**: Admin interface components and user interactions
- **Permission Tests**: Role-based access control and UI restrictions
- **Integration Tests**: Complete admin workflows and data management
- **Chart Tests**: Analytics visualization accuracy and responsiveness

### Test Coverage Goals
- Backend: 90%+ coverage for admin and analytics logic
- Frontend: 85%+ coverage for admin components
- End-to-end: Critical admin workflows (login → manage orders → update menu)

## Security Considerations

### Admin Authentication
- Strong password requirements for admin accounts
- Session timeout for inactive admin users
- Multi-factor authentication for super admin accounts
- Admin activity logging and audit trails

### Role-Based Access Control
- Granular permissions based on admin roles
- API endpoint protection with role verification
- UI component rendering based on permissions
- Resource-level access control

### Data Protection
- Sensitive customer data access logging
- Admin action audit trails
- Secure file upload handling for menu images
- Data export restrictions and logging

## Performance Considerations

### Backend Optimization
- Database indexing for admin queries (orders, users, analytics)
- Caching for dashboard statistics and analytics data
- Pagination for large datasets (orders, users, reports)
- Background job processing for heavy analytics calculations

### Frontend Optimization
- Lazy loading for admin dashboard components
- Virtual scrolling for large data tables
- Chart data caching and incremental updates
- Optimized image handling for menu management

### Analytics Performance
- Pre-calculated daily/weekly/monthly aggregations
- Efficient database queries with proper indexing
- Caching layer for frequently accessed analytics
- Asynchronous report generation for large datasets

## Real-time Features

### Order Notifications
- WebSocket connection for real-time order updates
- Push notifications for new orders
- Status change notifications
- Priority alerts for urgent orders

### Dashboard Updates
- Real-time sales metrics updates
- Live order count and status changes
- Automatic refresh for critical data
- Background data synchronization