defmodule HologramFeatureTests.NavigationTest do
  use HologramFeatureTests.TestCase, async: true

  alias HologramFeatureTests.Navigation1Page, as: Page1
  alias HologramFeatureTests.Navigation2Page, as: Page2
  alias HologramFeatureTests.Navigation3Page, as: Page3

  feature "link component, without params", %{session: session} do
    session
    |> visit(Page1)
    |> click(link("Page 2 link"))
    |> assert_page(Page2)
    |> assert_text("Page 2 title")
    |> click(button("Put page 2 result A"))
    |> assert_text("Page 2 result A")
  end

  feature "link component, with params", %{session: session} do
    session
    |> visit(Page1)
    |> click(link("Page 3 link"))
    |> assert_page(Page3, s: "abc", i: "123")
    |> assert_text("Page 3 title")
    |> assert_text(~s/%{i: 123, s: "abc"}/)
    |> click(button("Put page 3 result"))
    |> assert_text("Page 3 result")
  end

  feature "go back", %{session: session} do
    session
    |> visit(Page1)
    |> click(button("Put page 1 result A"))
    |> click(link("Page 2 link"))
    |> assert_page(Page2)
    |> go_back()
    |> assert_page(Page1)
    |> assert_text("Page 1 title")
    |> assert_text("Page 1 result A")
    |> click(button("Put page 1 result B"))
    |> assert_text("Page 1 result B")
  end

  feature "go back after reload", %{session: session} do
    session
    |> visit(Page1)
    |> click(button("Put page 1 result A"))
    |> click(link("Page 2 link"))
    |> assert_page(Page2)
    |> reload()
    |> assert_page(Page2)
    |> go_back()
    |> assert_page(Page1)
    |> assert_text("Page 1 title")
    |> assert_text("Page 1 result A")
    |> click(button("Put page 1 result B"))
    |> assert_text("Page 1 result B")
  end

  feature "go back to Hologram page (from non-Hologram page)", %{session: session} do
    session
    |> visit(Page1)
    |> click(button("Put page 1 result A"))
    |> assert_text("Page 1 result A")
    |> visit("https://www.wikipedia.org/")
    |> assert_text("Wikipedia")
    |> go_back()
    |> assert_page(Page1)
    |> assert_text("Page 1 title")
    |> assert_text("Page 1 result A")
    |> click(button("Put page 1 result B"))
    |> assert_text("Page 1 result B")
  end

  feature "go forward", %{session: session} do
    session
    |> visit(Page1)
    |> click(link("Page 2 link"))
    |> assert_page(Page2)
    |> click(button("Put page 2 result A"))
    |> go_back()
    |> assert_page(Page1)
    |> go_forward()
    |> assert_page(Page2)
    |> assert_text("Page 2 title")
    |> assert_text("Page 2 result A")
    |> click(button("Put page 2 result B"))
    |> assert_text("Page 2 result B")
  end

  feature "go forward after reload", %{session: session} do
    session
    |> visit(Page1)
    |> click(link("Page 2 link"))
    |> assert_page(Page2)
    |> click(button("Put page 2 result A"))
    |> go_back()
    |> assert_page(Page1)
    |> reload()
    |> assert_page(Page1)
    |> go_forward()
    |> assert_page(Page2)
    |> assert_text("Page 2 title")
    |> assert_text("Page 2 result A")
    |> click(button("Put page 2 result B"))
    |> assert_text("Page 2 result B")
  end

  feature "go forward to Hologram page (from non-Hologram page)", %{session: session} do
    session
    |> visit("https://www.wikipedia.org/")
    |> assert_text("Wikipedia")
    |> visit(Page1)
    |> click(button("Put page 1 result A"))
    |> assert_text("Page 1 result A")
    |> go_back()
    |> assert_text("Wikipedia")
    |> go_forward()
    |> assert_page(Page1)
    |> assert_text("Page 1 title")
    |> assert_text("Page 1 result A")
    |> click(button("Put page 1 result B"))
    |> assert_text("Page 1 result B")
  end

  feature "put page in action", %{session: session} do
    session
    |> visit(Page1)
    |> click(button("Change page"))
    |> assert_page(Page2)
    |> assert_text("Page 2 title")
    |> click(button("Put page 2 result A"))
    |> assert_text("Page 2 result A")
  end
end
