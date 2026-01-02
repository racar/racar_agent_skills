---
name: ruby-rails
description: Ruby on Rails 8 and Ruby 3.2 backend development. Use when working on Rails applications, API development, ActiveRecord models, database migrations, service objects, serializers, RSpec testing, or Ruby code optimization. Triggers on Rails-specific patterns like controllers, models, migrations, jobs, concerns, serializers, and Rails configuration.
---

# Ruby on Rails 8 Development

## Technology Stack

- **Ruby**: 3.2
- **Rails**: 8.0
- **Database**: PostgreSQL
- **Testing**: RSpec
- **API**: RESTful APIs, JSON serialization

## Rails 8 Key Features

### Modern Defaults

- **Solid Cable**: Built-in WebSocket support (replaces Action Cable Redis dependency)
- **Solid Cache**: Database-backed caching
- **Solid Queue**: Database-backed job queue (alternative to Sidekiq/Resque)
- **Kamal**: Built-in deployment tool
- **Propshaft**: Modern asset pipeline (default over Sprockets)
- **Authentication Generator**: `rails generate authentication`

### Code Style & Conventions

**Frozen String Literals**
```ruby
# frozen_string_literal: true
```
Always add to the top of every Ruby file.

**File Structure**
- Always add final newline to end of files
- Use 2-space indentation
- Follow Ruby style guide conventions

**Method Length**
- Keep methods under 10 lines
- Extract to private methods if needed
- Prefer composition over complexity

**Naming Conventions**
- Use domain vocabulary consistently
- Follow Rails naming conventions (plural controllers, singular models)
- Use descriptive method names that reveal intent

## ActiveRecord Patterns

### Models

```ruby
# frozen_string_literal: true

class User < ApplicationRecord
  # Associations
  has_many :orders, dependent: :destroy
  belongs_to :organization

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_save :normalize_email

  private

  def normalize_email
    self.email = email.downcase.strip
  end
end
```

### Migrations

```ruby
# frozen_string_literal: true

class AddStatusToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :status, :string, default: 'pending', null: false
    add_index :orders, :status
  end
end
```

**Migration Best Practices**
- Use `change` when possible (reversible)
- Add indexes for foreign keys and frequently queried columns
- Set defaults and null constraints at database level
- Use `up`/`down` for complex non-reversible migrations

### Queries

```ruby
# Good: Efficient queries
User.includes(:orders).where(active: true)
User.joins(:orders).select('users.*, COUNT(orders.id) as order_count').group('users.id')

# Bad: N+1 queries
users.each { |user| user.orders.count }
```

## Service Objects & Business Logic

**When to Use Service Objects**
- Complex business logic
- Multi-model operations
- External API interactions
- Operations requiring multiple steps

```ruby
# frozen_string_literal: true

module Orders
  class CreateService
    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      order = build_order
      return failure(order.errors) unless order.save

      notify_user(order)
      success(order)
    end

    private

    attr_reader :user, :params

    def build_order
      user.orders.build(params)
    end

    def notify_user(order)
      OrderMailer.confirmation(order).deliver_later
    end

    def success(order)
      { success: true, order: order }
    end

    def failure(errors)
      { success: false, errors: errors }
    end
  end
end
```

## Controllers

**RESTful Controllers**
```ruby
# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :set_order, only: %i[show update destroy]

  def index
    orders = Order.includes(:user).page(params[:page])
    render json: orders
  end

  def show
    render json: @order
  end

  def create
    result = Orders::CreateService.new(
      user: current_user,
      params: order_params
    ).call

    if result[:success]
      render json: result[:order], status: :created
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:amount, :description)
  end
end
```

**Controller Best Practices**
- Keep controllers thin (logic in services/models)
- Use `before_action` for shared setup
- Use strong parameters
- Return appropriate HTTP status codes

## Serializers

**ActiveModel Serializers Pattern**
```ruby
# frozen_string_literal: true

class OrderSerializer
  def initialize(order)
    @order = order
  end

  def as_json
    {
      id: order.id,
      amount: order.amount,
      status: order.status,
      user: user_data,
      created_at: order.created_at.iso8601
    }
  end

  private

  attr_reader :order

  def user_data
    {
      id: order.user.id,
      name: order.user.name,
      email: order.user.email
    }
  end
end
```

## Background Jobs

**Rails 8 with Solid Queue**
```ruby
# frozen_string_literal: true

class OrderProcessingJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(order_id)
    order = Order.find(order_id)
    Orders::ProcessService.new(order).call
  end
end

# Enqueue
OrderProcessingJob.perform_later(order.id)
```

## Testing with RSpec

### Model Specs

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:orders) }
  end

  describe '.active' do
    let!(:active_user) { create(:user, active: true) }
    let!(:inactive_user) { create(:user, active: false) }

    it 'returns only active users' do
      expect(described_class.active).to contain_exactly(active_user)
    end
  end
end
```

### Service Specs

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orders::CreateService do
  describe '#call' do
    let(:user) { create(:user) }
    let(:params) { { amount: 100, description: 'Test order' } }
    let(:service) { described_class.new(user: user, params: params) }

    context 'with valid params' do
      it 'creates an order' do
        expect { service.call }.to change(Order, :count).by(1)
      end

      it 'returns success result' do
        result = service.call
        expect(result[:success]).to be true
        expect(result[:order]).to be_a(Order)
      end
    end

    context 'with invalid params' do
      let(:params) { { amount: nil } }

      it 'does not create an order' do
        expect { service.call }.not_to change(Order, :count)
      end

      it 'returns failure result' do
        result = service.call
        expect(result[:success]).to be false
        expect(result[:errors]).to be_present
      end
    end
  end
end
```

### Controller Specs

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrdersController do
  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:valid_params) { { order: { amount: 100, description: 'Test' } } }

    before { sign_in user }

    context 'with valid parameters' do
      it 'creates a new order' do
        expect {
          post :create, params: valid_params
        }.to change(Order, :count).by(1)
      end

      it 'returns created status' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { order: { amount: nil } } }

      it 'does not create an order' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Order, :count)
      end

      it 'returns unprocessable entity status' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
```

## Common Patterns

### Concerns (Mixins)

```ruby
# frozen_string_literal: true

module Timestampable
  extend ActiveSupport::Concern

  included do
    scope :recent, -> { order(created_at: :desc) }
  end

  def age_in_days
    (Time.current - created_at) / 1.day
  end
end

# Usage
class Order < ApplicationRecord
  include Timestampable
end
```

### Callbacks

```ruby
# Good: Simple callbacks
before_validation :normalize_fields
after_create :send_notification

# Avoid: Complex logic in callbacks (use service objects instead)
```

### Scopes

```ruby
# Good: Chainable scopes
scope :active, -> { where(active: true) }
scope :recent, -> { order(created_at: :desc) }
scope :by_status, ->(status) { where(status: status) if status.present? }

# Usage
Order.active.recent.by_status('pending')
```

## Performance Optimization

### Eager Loading

```ruby
# N+1 query problem
users = User.all
users.each { |user| puts user.orders.count }

# Solution: eager loading
users = User.includes(:orders)
users.each { |user| puts user.orders.count }
```

### Database Indexes

```ruby
add_index :orders, :user_id
add_index :orders, :status
add_index :orders, [:user_id, :status]
add_index :users, :email, unique: true
```

### Caching

```ruby
# Fragment caching
<% cache order do %>
  <%= render order %>
<% end %>

# Low-level caching
Rails.cache.fetch("user_#{user.id}_orders", expires_in: 1.hour) do
  user.orders.to_a
end
```

## Configuration

### Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :orders, only: %i[index show create update destroy]
      resources :users do
        resources :orders, only: %i[index create]
      end
    end
  end
end
```

### Environment Variables

```ruby
# Use Rails credentials for secrets (Rails 8 default)
Rails.application.credentials.secret_key_base
Rails.application.credentials.database_password

# Or use ENV variables
database_url = ENV.fetch('DATABASE_URL')
```

## Common Mistakes to Avoid

1. **N+1 Queries**: Always use `includes`, `joins`, or `preload`
2. **Fat Controllers**: Move business logic to services/models
3. **Missing Indexes**: Add indexes for foreign keys and queried columns
4. **Callback Hell**: Use service objects for complex workflows
5. **Ignoring Strong Parameters**: Always whitelist params
6. **Missing Validations**: Validate at both model and database level
7. **Not Using Transactions**: Wrap multi-step operations in transactions
8. **Ignoring Background Jobs**: Don't block requests with slow operations

## Rails 8 Upgrade Notes

**From Rails 7 to Rails 8**
- Consider migrating to Solid Queue/Cache/Cable
- Update to Propshaft if using Sprockets
- Review authentication generator for new apps
- Check for deprecated methods and patterns
- Update dependencies to Rails 8 compatible versions

## Code Quality

### Testing & Linting Workflow (MUST Follow)

**Step 1: Run Tests First**
```bash
# Run all tests
docker exec -t <container-name> bundle exec rspec

# Run specific test file
docker exec -t <container-name> bundle exec rspec spec/path/to/file_spec.rb
```

**Step 2: Run RuboCop After Tests Pass (MANDATORY)**
```bash
# Run rubocop after rspec passes
docker exec -t <container-name> rubocop
```

**CRITICAL REQUIREMENT (C-11)**:
- RuboCop MUST be run AFTER rspec passes
- Ensure NO offenses are detected
- Replace `<container-name>` with actual container name (e.g., `service-setup-provider-1`)
- All code must pass both RSpec tests AND RuboCop checks before committing

## API Development

### Versioning

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :orders
  end

  namespace :v2 do
    resources :orders
  end
end
```

### Error Handling

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  private

  def not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { errors: exception.record.errors }, status: :unprocessable_entity
  end
end
```

### Response Formats

```ruby
# Success
render json: { data: resource, message: 'Success' }, status: :ok

# Created
render json: { data: resource }, status: :created

# Error
render json: { errors: ['Error message'] }, status: :unprocessable_entity

# Not Found
render json: { error: 'Resource not found' }, status: :not_found
```

## Security

**Mass Assignment Protection**
```ruby
params.require(:user).permit(:name, :email, :password)
```

**SQL Injection Prevention**
```ruby
# Good: Parameterized queries
User.where('email = ?', params[:email])
User.where(email: params[:email])

# Bad: String interpolation
User.where("email = '#{params[:email]}'")
```

**Authentication & Authorization**
```ruby
# Use Devise, Rodauth, or Rails 8 authentication generator
before_action :authenticate_user!
before_action :authorize_user!
```
