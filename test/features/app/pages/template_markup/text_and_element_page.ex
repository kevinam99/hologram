defmodule HologramFeatureTests.TemplateMarkup.TextAndElementPage do
  use Hologram.Page

  route "/template-markup/text-and-element"

  layout HologramFeatureTests.Components.DefaultLayout

  def template do
    ~H"""
    <div class="parent_elem">
      <span class="child_elem">my text</span>
    </div>
    """
  end
end
