require 'test_helper'

class HdiHelperTest < ActionView::TestCase
  include HdiHelper

  setup do
    @item = { label: 'Home', path: root_path, options: { data: { test: 'foo' }, icon: 'home' } }
  end

  test 'active sidebar_navigation_svg' do
    stubs(:current_page?).returns(true)

    @output_buffer = ActionView::OutputBuffer.new(hdi_sidebar_navigation_svg(@item))
    assert_select "a[data-test='foo'].sidebar-item.sidebar-item--active", /Home\z/ do
      assert_select 'a[href=?]', root_path
      assert_select 'img[src=?]', '/design_system/static/heroicons-2.1.5/icon-home.svg'
    end
  end

  test 'inactive sidebar_navigation_svg' do
    stubs(:current_page?).returns(false)

    @output_buffer = ActionView::OutputBuffer.new(hdi_sidebar_navigation_svg(@item))
    assert_select "a[data-test='foo'].sidebar-item", /Home\z/ do
      assert_select 'a[href=?]', root_path
      assert_select 'img[src=?]', '/design_system/static/heroicons-2.1.5/icon-home.svg'
    end
  end

  test 'sidebar_navigation_svg without an icon renders no image' do
    stubs(:current_page?).returns(false)

    @output_buffer = ActionView::OutputBuffer.new(
      hdi_sidebar_navigation_svg(label: 'Grid', path: '/styles/grid', options: { group: 'Styles' })
    )
    assert_select 'a.sidebar-item', text: 'Grid'
    assert_select 'a[group]', count: 0
    assert_select 'img', count: 0
  end

  test 'navigation_groups keeps ungrouped items first then groups in order' do
    items = [
      { label: 'Manage Assistants', path: '/assistants', options: {} },
      { label: 'Grid', path: '/styles/grid', options: { group: 'Styles', group_icon: 'book-open' } },
      { label: 'Panel', path: '/components/panel', options: { group: 'Components' } },
      { label: 'Headings', path: '/styles/headings', options: { group: 'Styles', group_icon: 'book-open' } }
    ]

    groups = hdi_navigation_groups(items)

    assert_equal [nil, 'Styles', 'Components'], groups.pluck(:heading)
    assert_equal ['Manage Assistants'], groups[0][:items].pluck(:label)
    assert_equal %w[Grid Headings], groups[1][:items].pluck(:label)
    assert_equal 'book-open', groups[1][:icon]
  end
end
