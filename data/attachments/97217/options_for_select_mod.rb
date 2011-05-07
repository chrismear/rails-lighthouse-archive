################################################################################################
# The following two methods are ment to be dropped into ActionView::Helpers::FormOptionsHelper #
################################################################################################

  def options_for_select(container, selected = nil)
    container = container.to_a if Hash === container

    options_for_select = container.inject([]) do |options, element|
      
      element = element.to_a.flatten unless Array === element # NOTE: added to avoid errors when using .reject method
      html_options = html_attributes_from(element)            # NOTE: added to collect attributes from element
      element.reject! {|i| Hash === i}                        # NOTE: added to remove attributes from element
      
      text, value = option_text_and_value(element)
      selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
      # NOTE: following is modified to interpolate html_options by adding only: #{html_options}
      options << %(<option value="#{html_escape(value.to_s)}"#{html_options}#{selected_attribute}>#{html_escape(text.to_s)}</option>)
    end

    options_for_select.join("\n")
  end
################################################
# The following is ment to be a private method #
################################################
  def html_attributes_from(element)
    # string of html_attributes from hash data in element
    element.reject {|i| i unless Hash === i}.inject({}) {|a,i| a.merge i }.collect {|k,v| %( #{k}="#{v}")}.join
  end


################### ################### ################### ###################  ###################
###### Tests ###### ###### Tests ###### ###### Tests ###### ###### Tests ######  ###### Tests ######
################### ################### ################### ###################  ###################

# Tests for options_for_select
def test_options_for_select_with_element_attributes
  assert_dom_equal(
    "<option value=\"&lt;Denmark&gt;\" class=\"bold\">&lt;Denmark&gt;</option>\n<option value=\"USA\" onclick=\"alert('Hello World');\">USA</option>\n<option value=\"Sweden\">Sweden</option>\n<option value=\"Germany\">Germany</option>",
    options_for_select([ ["<Denmark>", {:class=>'bold'}], ["USA", {:onclick => "alert('Hello World');"}], {"Sweden" => "Sweden"}, "Germany"])
  )
end
def test_options_for_select_with_element_attributes_and_selection
  assert_dom_equal(
    "<option value=\"&lt;Denmark&gt;\">&lt;Denmark&gt;</option>\n<option value=\"USA\" class=\"bold\" selected=\"selected\">USA</option>\n<option value=\"Sweden\">Sweden</option>",
    options_for_select([ "<Denmark>", ["USA", {:class=>'bold'}], "Sweden" ], "USA")
  )
end
def test_options_for_select_with_element_attributes_and_selection_array
  assert_dom_equal(
    "<option value=\"&lt;Denmark&gt;\">&lt;Denmark&gt;</option>\n<option value=\"USA\" class=\"bold\" selected=\"selected\">USA</option>\n<option value=\"Sweden\" selected=\"selected\">Sweden</option>",
    options_for_select([ "<Denmark>", ["USA", {:class=>'bold'}], "Sweden" ], ["USA", "Sweden"])
  )
end

# tests for array_html_attributes_from_
def test_array_html_attributes_from_without_hash
  assert_dom_equal( html_attributes_from(
    ['one','one']),
    "" 
  )
end
def test_array_html_attributes_from_with_single_element_hash
  assert_dom_equal(
    html_attributes_from(['one','one',{:class => 'fancy'}]),
    " class=\"fancy\""
  )
end
def test_array_html_attributes_from_with_multiple_element_hash
  assert_dom_equal(
    html_attributes_from(['one','one',{:class => 'fancy', 'onclick' => "alert('Hello World');"}]),
    " class=\"fancy\" onclick=\"alert('Hello World');\""
  )
end
def test_array_html_attributes_from_with_multiple_hashes
  assert_dom_equal(
    html_attributes_from(['one','one',{:class => 'fancy'}, {'onclick' => "alert('Hello World');"}]),
    " class=\"fancy\" onclick=\"alert('Hello World');\""
  )
end