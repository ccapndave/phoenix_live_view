defmodule Phoenix.LiveView.ViewTest do
  use ExUnit.Case, async: true

  alias Phoenix.LiveView.{View, Socket}
  alias Phoenix.LiveViewTest.Endpoint

  @socket View.configure_socket(%Socket{endpoint: Endpoint}, %{connect_params: %{}})

  describe "get_connect_params" do
    test "raises when not in mounting state and connected" do
      socket = View.post_mount_prune(%{@socket | connected?: true})

      assert_raise RuntimeError, ~r/attempted to read connect_params/, fn ->
        View.get_connect_params(socket)
      end
    end

    test "raises when not in mounting state and disconnected" do
      socket = View.post_mount_prune(%{@socket | connected?: false})

      assert_raise RuntimeError, ~r/attempted to read connect_params/, fn ->
        View.get_connect_params(socket)
      end
    end

    test "returns nil when disconnected" do
      socket = %{@socket | connected?: false}
      assert View.get_connect_params(socket) == nil
    end

    test "returns params connected and mounting" do
      socket = %{@socket | connected?: true}
      assert View.get_connect_params(socket) == %{}
    end
  end

  describe "assign_new" do
    test "uses socket assigns if no parent assigns are present" do
      socket =
        @socket
        |> View.assign(existing: "existing")
        |> View.assign_new(:existing, fn -> "new-existing" end)
        |> View.assign_new(:notexisting, fn -> "new-notexisting" end)

      assert socket.assigns == %{existing: "existing", notexisting: "new-notexisting"}
    end

    test "uses parent assigns when present and falls back to socket assigns" do
      socket =
        put_in(@socket.private[:assigned_new], {%{existing: "existing-parent"}, []})
        |> View.assign(existing2: "existing2")
        |> View.assign_new(:existing, fn -> "new-existing" end)
        |> View.assign_new(:existing2, fn -> "new-existing2" end)
        |> View.assign_new(:notexisting, fn -> "new-notexisting" end)

      assert socket.assigns == %{
               existing: "existing-parent",
               existing2: "existing2",
               notexisting: "new-notexisting"
             }
    end
  end
end
