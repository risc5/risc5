import urllib.parse
import os

def parse_vless(vless_url, index):
    """解析单个 VLESS 链接并返回格式化的 YAML 字符串"""
    try:
        parsed = urllib.parse.urlparse(vless_url.strip())
        if parsed.scheme != 'vless':
            return None

        # 提取基本信息
        uuid = parsed.username
        server = parsed.hostname
        port = parsed.port
        params = urllib.parse.parse_qs(parsed.query)
        
        # 处理备注名称
        raw_fragment = urllib.parse.unquote(parsed.fragment)
        # 取第一个分隔符前的名称，并附上索引防止重名
        clean_name = f"{raw_fragment.split('|')[0]}_{index}"

        # 核心逻辑映射
        node = {
            "name": clean_name,
            "server": server,
            "port": port,
            "type": "vless",
            "uuid": uuid,
            "tls": params.get('security', [''])[0] in ['tls', 'reality'],
            "network": params.get('type', ['tcp'])[0],
            "servername": params.get('sni', [''])[0],
            "client-fingerprint": params.get('fp', ['chrome'])[0],
            "public_key": params.get('pbk', [''])[0]
        }

        # 构建紧凑的单行 YAML 格式
        yaml_line = (
            f"- {{name: {node['name']}, server: {node['server']}, port: {node['port']}, "
            f"type: {node['type']}, uuid: {node['uuid']}, tls: {str(node['tls']).lower()}, "
            f"network: {node['network']}, servername: {node['servername']}, "
            f"client-fingerprint: {node['client-fingerprint']}, "
            f"reality-opts: {{public-key: {node['public_key']}}}}}"
        )
        return yaml_line
    except Exception:
        return None

def batch_convert(input_file, output_file):
    if not os.path.exists(input_file):
        print(f"错误: 找不到输入文件 '{input_file}'")
        return

    with open(input_file, 'r', encoding='utf-8') as f:
        urls = f.readlines()

    results = []
    count = 0
    for url in urls:
        if url.strip():
            yaml_node = parse_vless(url, count)
            if yaml_node:
                results.append(yaml_node)
                count += 1

    with open(output_file, 'w', encoding='utf-8') as f:
        # 写入简单的头部标识，方便手动粘贴
        f.write("# Proxies List\n")
        f.write("\n".join(results))
    
    print(f"成功转换 {len(results)} 个节点，已保存至: {output_file}")

if __name__ == "__main__":
    # 你可以根据实际文件名修改这里
    input_txt = "urls.txt"
    output_yaml = "proxies.yaml"
    batch_convert(input_txt, output_yaml)
