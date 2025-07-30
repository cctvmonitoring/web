// 테스트 주석1
const { Server } = require('socket.io');
const http = require('http');
const WebSocket = require('ws');

const SOCKETIO_PORT = 5005; // Flutter 웹과 통신
const WS_PORT = 6001;       // 라즈베리파이와 통신

// 성능 측정 변수들
let frameCount = 0;
let totalDataSize = 0;
let startTime = Date.now();
let latencySum = 0;
let latencyCount = 0;

const server = http.createServer();
const io = new Server(server, { 
  cors: { 
    origin: "*",
    methods: ["GET", "POST"],
    credentials: true
  },
  allowEIO3: true,
  transports: ['websocket', 'polling']
});
server.listen(SOCKETIO_PORT, () => {
  console.log('✅ Socket.IO server running on port', SOCKETIO_PORT);
});

const wss = new WebSocket.Server({ port: WS_PORT }, () => {
  console.log('✅ WebSocket server running on port', WS_PORT);
});

// 성능 측정 출력 (1초마다)
setInterval(() => {
  const elapsed = (Date.now() - startTime) / 1000;
  const fps = frameCount / elapsed;
  const avgDataSize = totalDataSize / frameCount;
  const avgLatency = latencyCount > 0 ? latencySum / latencyCount : 0;
  const memoryUsage = process.memoryUsage();
  
  console.log('📊 Performance Metrics:');
  console.log(`   FPS: ${fps.toFixed(2)}`);
  console.log(`   Avg Data Size: ${(avgDataSize / 1024).toFixed(2)} KB`);
  console.log(`   Avg Latency: ${avgLatency.toFixed(2)} ms`);
  console.log(`   Memory Usage: ${Math.round(memoryUsage.heapUsed / 1024 / 1024)} MB`);
  console.log(`   Total Frames: ${frameCount}`);
  console.log('---');
}, 1000);

wss.on('connection', (ws) => {
  console.log('🔗 Raspberry Pi connected via WebSocket');
  
  // 연결된 클라이언트 정보 출력
  console.log('📊 Active WebSocket connections:', wss.clients.size);
  
  ws.on('message', (message) => {
    const messageStartTime = Date.now();
    console.log('📨 Raw message received, length:', message.length);
    
    try {
      const data = JSON.parse(message);
      console.log(`📡 Received data from Raspberry Pi: stream_name=${data.stream_name}, image_length=${data.image?.length}, detections=${data.detections?.length}`);
      
      // 성능 측정
      frameCount++;
      totalDataSize += message.length;
      
      // Socket.IO로 전송
      io.emit('stream1', data);
      console.log(`📤 Sent data to Flutter via Socket.IO: stream1`);
      
      // 지연시간 측정
      const latency = Date.now() - messageStartTime;
      latencySum += latency;
      latencyCount++;
      
    } catch (e) {
      console.error('❌ Invalid message:', e);
      console.error('Raw message preview:', message.toString().substring(0, 200));
    }
  });
  
  ws.on('close', () => {
    console.log('🔌 Raspberry Pi WebSocket disconnected');
    console.log('📊 Remaining WebSocket connections:', wss.clients.size);
  });
  
  ws.on('error', (error) => {
    console.error('❌ WebSocket error:', error);
  });
});

// Socket.IO 클라이언트 연결 처리
io.on('connection', (socket) => {
  console.log('🌐 Flutter client connected via Socket.IO');
  console.log('📊 Active Socket.IO connections:', io.engine.clientsCount);
  
  socket.on('disconnect', () => {
    console.log('🌐 Flutter client disconnected');
    console.log('📊 Remaining Socket.IO connections:', io.engine.clientsCount);
  });
  
  socket.on('error', (error) => {
    console.error('❌ Socket.IO error:', error);
  });
});