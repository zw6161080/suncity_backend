class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end


  def download?
    true
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end

    def can?(action, resource = nil)

      currect_resource = resource || find_currect_resource(scope.name)
      user && user.can?(action, currect_resource)
    end

    def find_currect_resource (old_resource)
      currect_permission = Config.get('permission_selects')["permissions"].find do |permission|
        filter_child(permission["child"], old_resource)
      end
      currect_resource = currect_permission ? currect_permission['resource'] : nil
      currect_resource || old_resource
    end

    def filter_child (child, resource)
      current_child = child.select do |child_resource|
        child_resource == resource
      end
      if current_child.length > 0
        return true
      else
        return false
      end
    end

  end

  class << self
    def policies
      @policies ||= Dir.chdir(Rails.root.join('app/policies')) do
        Dir['**/*_policy.rb'].collect do |file|
          file.chomp('.rb').camelize.constantize unless file == File.basename(__FILE__)
        end.compact
      end
    end

    def resource
      name.chomp('Policy')
    end

    def actions
      @actions ||= []
    end

    def permit(*actions)
      acts = actions.collect(&:to_s)
      acts.each do |act|
        define_method("#{act}?") { can? act }
      end
      actions.concat(acts)
    end

    def power(*actions)
      @actions = actions
    end

  end

  private

  def can?(action, strong_resource = nil)
    resource = record.is_a?(Class) ? record.name : record.class.name
    currect_resource = strong_resource || find_currect_resource(action, resource)
    user.can?(action, currect_resource)
  end

  def find_currect_resource (action, old_resource)
    currect_permission = Config.get('permission_selects')["permissions"].find do |permission|
      filter_child(permission["child"], old_resource) if permission['action'].to_sym == action
    end
    currect_resource = currect_permission ? currect_permission['resource'] : nil
    currect_resource || old_resource
  end

  def filter_child (child, resource)
    current_child = child.select do |child_resource|
      child_resource == resource
    end
    if current_child.length > 0
      return true
    else
      return false
    end
  end
end
