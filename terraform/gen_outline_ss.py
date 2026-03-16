import json
import urllib.request
import ssl
import sys
import re

def generate_clean_ss_link(log_file_path):
    try:
        # 1. 读取日志文件
        with open(log_file_path, 'r') as f:
            log_content = f.read()

        # 2. 提取 API 配置 JSON
        match = re.search(r'\{"apiUrl":"https://[^"]+","certSha256":"[^"]+"\}', log_content)
        if not match:
            return "错误：在日志中未找到 Outline API 配置信息。"

        config = json.loads(match.group(0))
        api_url = config['apiUrl'] + '/access-keys'

        # 3. 请求创建新的 Access Key
        context = ssl._create_unverified_context()
        req = urllib.request.Request(api_url, method='POST')

        with urllib.request.urlopen(req, context=context) as response:
            result = json.loads(response.read().decode())
            raw_url = result.get('accessUrl', '')

            # 4. 【核心逻辑】去掉 ?outline=1 后缀
            # 使用 split('?') 分割字符串并取第一部分
            clean_url = raw_url.split('?')[0]
            
            return clean_url

    except Exception as e:
        return f"转换失败：{str(e)}"

if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else '/root/outline_install.log'
    ss_link = generate_clean_ss_link(path)
    
    print("\n" + "="*60)
    print("🎉 你的标准 Shadowsocks (SS) 客户端连接地址：")
    print(ss_link)
    print("="*60 + "\n")
