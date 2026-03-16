import urllib.request
import json
import time
import sys

def get_my_ip():
    try:
        # 获取刚部署的服务器公网 IP
        req = urllib.request.Request('https://api.ipify.org')
        with urllib.request.urlopen(req, timeout=5) as response:
            return response.read().decode('utf8').strip()
    except Exception as e:
        print(f"❌ 获取本机 IP 失败: {e}")
        sys.exit(1)

def check_china_connectivity():
    ip = get_my_ip()
    print(f"📡 当前服务器 IP: {ip}")
    print("🔎 正在通过 Globalping 调度中国境内节点进行探测 (大约需要 5-10 秒)...")

    api_url = "https://api.globalping.io/v1/measurements"
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json"
    }
    
    # 负载：指定测试类型为 ping，目标为本机 IP，节点限制为中国 (CN)，数量 3 个
    payload = {
        "type": "ping",
        "target": ip,
        "locations": [{"country": "CN"}],
        "limit": 3
    }
    
    try:
        # 1. 提交测量任务 (POST)
        data = json.dumps(payload).encode('utf-8')
        req = urllib.request.Request(api_url, data=data, headers=headers, method='POST')
        
        with urllib.request.urlopen(req, timeout=10) as response:
            res_data = json.loads(response.read().decode('utf-8'))
            measurement_id = res_data.get("id")
            
        if not measurement_id:
            print("❌ 创建 Globalping 拨测任务失败")
            return

        # 2. 轮询获取测试结果 (GET)
        result_url = f"{api_url}/{measurement_id}"
        
        for _ in range(10): # 最多等 20 秒
            time.sleep(2)
            req_res = urllib.request.Request(result_url, headers={"Accept": "application/json"})
            with urllib.request.urlopen(req_res, timeout=10) as response:
                poll_data = json.loads(response.read().decode('utf-8'))
                
            status = poll_data.get("status")
            if status == "finished" or status == "partially-finished":
                break
            
        # 3. 解析测试结果
        results = poll_data.get("results", [])
        success_count = 0
        total_count = len(results)
        
        for probe in results:
            # 解析丢包率 (loss)。如果丢包率小于 100%，说明通了
            stats = probe.get("result", {}).get("stats", {})
            loss = stats.get("loss", 100)
            if loss < 100:
                success_count += 1
                
        # 4. 打印最终判断结论
        print("\n" + "="*70)
        if total_count == 0:
            print("⚠️ 未能获取到中国区探测节点的返回数据，可能 API 繁忙。")
        elif success_count > 0:
            print(f"✅ [SUCCESS] 中国区直连探测成功！({success_count}/{total_count} 个中国节点能 Ping 通)")
            print("🚀 网络状态良好，3秒后继续自动部署 Outline...")
            time.sleep(3) # 给用户时间看清提示
        else:
            print(f"❌ [WARNING] 中国区节点探测全部超时或丢包 100% ({success_count}/{total_count} 成功)")
            print("💡 结论：该 IP 极大概率已被中国大陆防火墙 (GFW) 封锁！")
            print("⚡ 强烈建议：请立即按下 【Ctrl + C】 中断部署，然后运行销毁命令重试！")
            print("⏳ 脚本将在此暂停 10 秒供你考虑，10秒后若未中断将强行继续部署...")
            time.sleep(10) # 故意卡住 10 秒，方便用户有充足时间按下 Ctrl+C
        print("="*70 + "\n")

    except Exception as e:
        print(f"💥 Globalping 检测请求出错: {e}")

if __name__ == "__main__":
    check_china_connectivity()
