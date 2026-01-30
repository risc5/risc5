//npm init -y
//npm install ws
//node wss_test.js

const WebSocket = require('ws');

// 在这里配置你需要测试的所有节点
const nodes = [
    { name: 'dRPC', url: 'wss://bsc.drpc.org' },
    { name: 'PublicNode', url: 'wss://bsc-rpc.publicnode.com' },
    { name: 'NodeReal', url: 'wss://bsc-mainnet.nodereal.io/ws/v1/你的API_KEY' }
];

console.log('🚀 开始多节点延迟对比测试...\n');
console.log('节点名称\t\t当前延迟\t平均延迟\t状态');
console.log('------------------------------------------------------------');

nodes.forEach(node => {
    let ws;
    try {
        ws = new WebSocket(node.url);
    } catch (e) {
        console.log(`${node.name}\t\t连接失败: ${e.message}`);
        return;
    }

    let latencies = [];
    let startTime;
    let isConnected = false;

    ws.on('open', () => {
        isConnected = true;
        // 每 2 秒发送一次心跳测试
        setInterval(() => {
            if (ws.readyState === WebSocket.OPEN) {
                startTime = Date.now();
                ws.send(JSON.stringify({
                    jsonrpc: "2.0",
                    id: 1,
                    method: "eth_blockNumber",
                    params: []
                }));
            }
        }, 2000);
    });

    ws.on('message', () => {
        const latency = Date.now() - startTime;
        latencies.push(latency);
        const avg = (latencies.reduce((a, b) => a + b) / latencies.length).toFixed(1);

        // 格式化输出：\x1b[32m 是绿色，\x1b[0m 是重置颜色
        process.stdout.write(`${node.name.padEnd(15)}\t${latency}ms\t\t${avg}ms\t\t\x1b[32m在线\x1b[0m\n`);
    });

    ws.on('error', (err) => {
        console.log(`${node.name.padEnd(15)}\t\x1b[31m错误: ${err.message.substring(0, 20)}\x1b[0m`);
    });

    ws.on('close', () => {
        console.log(`${node.name.padEnd(15)}\t\x1b[33m连接已断开\x1b[0m`);
    });
});
