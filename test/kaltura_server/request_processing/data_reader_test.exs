defmodule CtiKaltura.RequestProcessing.DataReaderTest do
  use CtiKaltura.PlugTestCase

  alias CtiKaltura.RequestProcessing.DataReader

  describe "#call" do
    setup do
      {:ok,
       ip_address: {123, 123, 123, 123},
       resource_id: "resource_1234",
       vod_path: "onlime/cowex/ru",
       nginx_ip: {10, 15, 2, 20}}
    end

    test "Direct request set assigns right. request: live, stream_meta: hls", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "hls",
                 encryption: "",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/live/hls/#{res_id}"), %{})
    end

    test "Direct request set assigns right. request: live, stream_meta: hls , with extension", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "hls",
                 encryption: "",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/live/hls/#{res_id}.m3u8"), %{})
    end

    test "Direct request set assigns right. request: live, stream_meta: mpd", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/live/mpd/#{res_id}"), %{})
    end

    test "Direct request set assigns right. request: live, stream_meta: mpd with extension", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/live/mpd/#{res_id}.mpd"), %{})
    end

    test "Direct request set assigns right. request: live, stream_meta: mpd_wv", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "wv",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/live/mpd_wv/#{res_id}"), %{})
    end

    test "Direct request set assigns right. request: live, stream_meta: mpd_pr", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "pr",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/live/mpd_pr/#{res_id}"), %{})
    end

    test "Direct request set assigns right. request: live, stream_meta: mpd_cenc", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "cenc",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/live/mpd_cenc/#{res_id}"), %{})
    end

    test "Direct request set assigns right. request: catchup, stream_meta: hls", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "hls",
                 encryption: "",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/catchup/hls/#{res_id}"), %{})
    end

    test "Direct request set assigns right. request: catchup, stream_meta: hls with extension", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "hls",
                 encryption: "",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/catchup/hls/#{res_id}.m3u8"), %{})
    end

    test "Direct request set assigns right. request: catchup, stream_meta: mpd", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/catchup/mpd/#{res_id}"), %{})
    end

    test "Direct request set assigns right. request: catchup, stream_meta: mpd with extension", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/catchup/mpd/#{res_id}.mpd"), %{})
    end

    test "Direct request set assigns right. request: catchup, stream_meta: mpd_wv", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "wv",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/catchup/mpd_wv/#{res_id}"), %{})
    end

    test "Direct request set assigns right. request: catchup, stream_meta: mpd_pr", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "pr",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/catchup/mpd_pr/#{res_id}"), %{})
    end

    test "Direct request set assigns right. request: catchup, stream_meta: mpd_cenc", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "cenc",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/catchup/mpd_cenc/#{res_id}"), %{})
    end

    test "Direct request set assigns right. request: vod", %{
      ip_address: ip_address,
      vod_path: vod_path
    } do
      assert %Plug.Conn{
               assigns: %{
                 ip_address: ^ip_address,
                 vod_path: ^vod_path
               }
             } = DataReader.call(build_conn(ip_address, "/vod/#{vod_path}"), %{})
    end

    test "Nginx proxy set assigns right. request: live, stream_meta: hls", %{
      ip_address: ip_address,
      resource_id: res_id,
      nginx_ip: nginx_ip
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "hls",
                 encryption: "",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } =
               DataReader.call(
                 build_nginx_proxy_conn(nginx_ip, ip_address, "/btv/live/hls/#{res_id}"),
                 %{}
               )
    end

    test "Nginx proxy set assigns right. request: live, stream_meta: mpd", %{
      ip_address: ip_address,
      resource_id: res_id,
      nginx_ip: nginx_ip
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } =
               DataReader.call(
                 build_nginx_proxy_conn(nginx_ip, ip_address, "/btv/live/mpd/#{res_id}"),
                 %{}
               )
    end

    test "Nginx proxy set assigns right. request: live, stream_meta: mpd_wv", %{
      ip_address: ip_address,
      resource_id: res_id,
      nginx_ip: nginx_ip
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "wv",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } =
               DataReader.call(
                 build_nginx_proxy_conn(nginx_ip, ip_address, "/btv/live/mpd_wv/#{res_id}"),
                 %{}
               )
    end

    test "Nginx proxy set assigns right. request: live, stream_meta: mpd_pr", %{
      ip_address: ip_address,
      resource_id: res_id,
      nginx_ip: nginx_ip
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "pr",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } =
               DataReader.call(
                 build_nginx_proxy_conn(nginx_ip, ip_address, "/btv/live/mpd_pr/#{res_id}"),
                 %{}
               )
    end

    test "Nginx proxy set assigns right. request: catchup, stream_meta: hls", %{
      ip_address: ip_address,
      resource_id: res_id,
      nginx_ip: nginx_ip
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "hls",
                 encryption: "",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } =
               DataReader.call(
                 build_nginx_proxy_conn(nginx_ip, ip_address, "/btv/catchup/hls/#{res_id}"),
                 %{}
               )
    end

    test "Nginx proxy set assigns right. request: catchup, stream_meta: mpd", %{
      ip_address: ip_address,
      resource_id: res_id,
      nginx_ip: nginx_ip
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } =
               DataReader.call(
                 build_nginx_proxy_conn(nginx_ip, ip_address, "/btv/catchup/mpd/#{res_id}"),
                 %{}
               )
    end

    test "Nginx proxy set assigns right. request: catchup, stream_meta: mpd_wv", %{
      ip_address: ip_address,
      resource_id: res_id,
      nginx_ip: nginx_ip
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "wv",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } =
               DataReader.call(
                 build_nginx_proxy_conn(nginx_ip, ip_address, "/btv/catchup/mpd_wv/#{res_id}"),
                 %{}
               )
    end

    test "Nginx proxy set assigns right. request: catchup, stream_meta: mpd_pr", %{
      ip_address: ip_address,
      resource_id: res_id,
      nginx_ip: nginx_ip
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 encryption: "pr",
                 resource_id: ^res_id,
                 ip_address: ^ip_address
               }
             } =
               DataReader.call(
                 build_nginx_proxy_conn(nginx_ip, ip_address, "/btv/catchup/mpd_pr/#{res_id}"),
                 %{}
               )
    end

    test "Nginx proxy set assigns right. request: vod", %{
      ip_address: ip_address,
      vod_path: vod_path,
      nginx_ip: nginx_ip
    } do
      assert %Plug.Conn{
               assigns: %{
                 ip_address: ^ip_address,
                 vod_path: ^vod_path
               }
             } =
               DataReader.call(
                 build_nginx_proxy_conn(nginx_ip, ip_address, "/vod/#{vod_path}"),
                 %{}
               )
    end

    test "Return plug assigns if request type is wrong", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      %Plug.Conn{assigns: response_assigns} =
        DataReader.call(build_conn(ip_address, "/btv/life/hls/#{res_id}"), %{})

      assert %{ip_address: ip_address} == response_assigns
    end

    test "Return plug assigns if request protocol is wrong", %{
      ip_address: ip_address,
      resource_id: res_id
    } do
      %Plug.Conn{assigns: response_assigns} =
        DataReader.call(build_conn(ip_address, "/btv/live/hlss/#{res_id}"), %{})

      assert %{ip_address: ip_address} == response_assigns
    end

    test "Return plug assigns if request resource format is wrong", %{
      ip_address: ip_address
    } do
      %Plug.Conn{assigns: response_assigns} =
        DataReader.call(build_conn(ip_address, "/btv/live/hls/asd123!"), %{})

      assert %{ip_address: ip_address} == response_assigns
    end
  end

  def build_conn(ip_address, path) do
    conn(:get, path)
    |> Map.put(:remote_ip, ip_address)
  end

  def build_nginx_proxy_conn(ip_address, {ip_seg1, ip_seg2, ip_seg3, ip_seg4}, path) do
    conn(:get, path)
    |> Map.put(:remote_ip, ip_address)
    |> Map.update!(:req_headers, fn headers_list ->
      headers_list ++ [{"x-real-ip", "#{ip_seg1}.#{ip_seg2}.#{ip_seg3}.#{ip_seg4}"}]
    end)
  end
end
