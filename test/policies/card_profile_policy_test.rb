require 'test_helper'

class CardProfilePolicyTest < ActiveSupport::TestCase

  def test_current_card_profile_by_user
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:information, :CardProfile, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert CardProfilePolicy.new(user, CardProfile).current_card_profile_by_user?
  end

  def test_scope
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :CardProfile, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert CardProfilePolicy.new(user, CardProfile).index?

  end

  def test_translate
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :CardProfile, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert CardProfilePolicy.new(user, CardProfile).translate?

  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :CardProfile, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert CardProfilePolicy.new(user, CardProfile).show?

  end



  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :CardProfile, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert CardProfilePolicy.new(user, CardProfile).create?

  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :CardProfile, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert CardProfilePolicy.new(user, CardProfile).update?

  end

  def test_destroy
  end

  def test_matching_search
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :CardProfile, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert CardProfilePolicy.new(user, CardProfile).matching_search?

  end

  def test_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :CardProfile, :macau)
    user= create_test_user
    user.add_role(admin_role)


    assert CardProfilePolicy.new(user, CardProfile).export_xlsx?
  end
end
