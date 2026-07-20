require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest
  test 'renders navigation links correctly with options' do
    nav_item = [
      { label: 'Test Item', path: '/test', options: { method: :delete } }
    ]

    ApplicationController.any_instance.stubs(:navigation_items).returns(nav_item)

    get root_path
    assert_response :success
    assert_select 'nav a[data-method="delete"]', text: 'Test Item'
  end

  test 'HDI sidebar groups the design system showcase into collapsible sections' do
    get styles_path
    assert_response :success

    # Grouped, collapsible section rows styled like default sidebar items
    %w[Styles Components Utilities].each do |heading|
      assert_select 'details.sidebar-group > summary.sidebar-item', text: /#{heading}/
    end

    # Section rows carry an icon, just like "Manage Assistants"
    assert_select 'details.sidebar-group > summary.sidebar-item img.hdi-icon'

    # Content links populated from the design system sections
    assert_select 'nav a.sidebar-item', text: /Grid/
    assert_select 'nav a.sidebar-item', text: /Panel/
  end

  test 'HDI sidebar shows app and brand links flat at the top, not grouped' do
    get styles_path
    assert_response :success

    # App link and brand switchers are flat sidebar items, not collapsible groups
    ['Manage Assistants', 'GOV.UK', 'NHS', 'HDI'].each do |label|
      assert_select 'nav a.sidebar-item', text: /#{Regexp.escape(label)}/
    end
    assert_select 'details.sidebar-group > summary', text: /Brand/, count: 0
  end
end
