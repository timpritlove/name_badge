defmodule NameBadge.Screen.Foo do
  use NameBadge.Screen

  @width 400
  @height 300
  @tick_interval_ms 10

  @impl NameBadge.Screen
  def mount(_args, screen) do
    Process.send_after(self(), :tick, @tick_interval_ms)

    {:ok, assign(screen, s: 0.0)}
  end

  @impl NameBadge.Screen
  def render(assigns) do
    bitmap =
      for n <- 0..(400 * 300 - 1) do
        x = rem(n, 400)
        y = div(n, 400)

        center_x = @width / 2
        center_y = @height / 2

        offset_x = :math.sin(assigns.s * 0.7) * 40
        offset_y = :math.sin(assigns.s * 0.9) * 30

        v = trunc(:math.sin(assigns.s * 4.0 - hypot(x - center_x + offset_x, y - center_y + offset_y) * 0.1) * 127) + 127

        {v, v, v}
      end

      pngex =
        Pngex.new()
        |> Pngex.set_type(:rgb)
        |> Pngex.set_depth(:depth8)
        |> Pngex.set_size(400, 300)

      png = pngex
        |> Pngex.generate(bitmap)
        |> IO.iodata_to_binary()

      png
        |> Dither.decode!()
        |> Dither.grayscale!()
        |> Dither.dither!()
        |> Dither.encode!()
  end

  @impl GenServer
  def handle_info(:tick, screen) do
    Process.send_after(self(), :tick, @tick_interval_ms)
    {:noreply, assign(screen, s: screen.assigns.s + 0.01)}
  end

  def hypot(a, b), do: :math.sqrt(a ** 2 + b ** 2)

end
