// const express = require('express');
// const app = express();
// const http = require('http').createServer(app);
// const io = require('socket.io')(http, {
//   cors: {
//     origin: "*",
//     methods: ["GET", "POST"]
//   }
// });
// const WebSocket = require('ws');

// // 미들웨어 설정
// app.use(express.json());
// app.use(express.urlencoded({ extended: true }));
// app.use(express.static('public'));

// // 기본 라우트
// app.get('/', (req, res) => {
//   res.send('CCTV Backend Server is running');
// });

// // 에러 핸들링 미들웨어
// app.use((err, req, res, next) => {
//   console.error('서버 에러:', err);
//   res.status(500).send('서버 에러가 발생했습니다.');
// });

// // 라즈베리파이 카메라 스트림 연결
// const raspberryPiUrl = 'ws://192.168.1.22:5000';
// let ws;

// function connectToRaspberryPi() {
//   ws = new WebSocket(raspberryPiUrl);

//   ws.on('open', () => {
//     console.log('라즈베리파이 카메라 스트림에 연결됨');
//   });

//   ws.on('message', (data) => {
//     try {
//       // 이미지 데이터를 그대로 전송
//       io.emit('stream', data);
//     } catch (error) {
//       console.error('스트림 데이터 처리 중 에러:', error);
//     }
//   });

//   ws.on('error', (error) => {
//     console.error('WebSocket 에러:', error);
//   });

//   ws.on('close', () => {
//     console.log('라즈베리파이 연결이 끊어짐. 재연결 시도...');
//     setTimeout(connectToRaspberryPi, 5000);
//   });
// }

// // Socket.IO 클라이언트 연결 처리
// io.on('connection', (socket) => {
//   console.log('클라이언트 연결됨');

//   socket.on('disconnect', () => {
//     console.log('클라이언트 연결 끊김');
//   });
// });

// // 서버 시작
// const PORT = process.env.PORT || 3000;
// http.listen(PORT, () => {
//   console.log(`서버가 포트 ${PORT}에서 실행 중입니다`);
//   connectToRaspberryPi();
// }); 

// // ✅ WebSocket 서버 설정 추가
// const WebSocket = require('ws');
// const wss = new WebSocket.Server({ port: 5000 });  // YOLO 서버가 연결

// // Socket.IO 그대로 유지
// const express = require('express');
// const app = express();
// const http = require('http').createServer(app);
// const io = require('socket.io')(http, {
//   cors: {
//     origin: "*",
//     methods: ["GET", "POST"]
//   }
// });

// // 정적 파일 및 라우팅 설정
// app.use(express.static('public'));
// app.get('/', (req, res) => {
//   res.send('CCTV Backend Server is running');
// });

// // ✅ WebSocket 연결 처리 (YOLO 서버가 연결)
// wss.on('connection', function connection(ws) {
//   console.log('[WebSocket] YOLO Server connected');

//   // ws.on('message', function incoming(data) {
//   //   // YOLO에서 받은 프레임을 Flutter로 전달
//   //   io.emit('stream', data);
//   // });
//   ws.on('message', function incoming(data) {
//     try {
//       const jsonString = data.toString();           // Buffer → 문자열
//       const parsed = JSON.parse(jsonString);        // 문자열 → JSON

//       const streamName = parsed.stream_name || 'unknown';

//       // 각 스트림 이름에 맞게 개별 전송
//       io.emit(streamName, parsed);  // 🔥 stream1, stream2 등 이름으로 이벤트 전송

//       console.log(`[WebSocket] 전송 완료 → ${streamName}`);

//     } catch (e) {
//       console.error('[WebSocket] JSON 처리 실패:', e);
//     }
// });


//   ws.on('close', () => {
//     console.log('[WebSocket] YOLO Server disconnected');
//   });

//   ws.on('error', (err) => {
//     console.error('[WebSocket] Error:', err);
//   });
// });

// // Socket.IO (Flutter 클라이언트)
// io.on('connection', (socket) => {
//   console.log('[Socket.IO] Flutter client connected');

//   socket.on('disconnect', () => {
//     console.log('[Socket.IO] Flutter client disconnected');
//   });
// });

// const PORT = process.env.PORT || 3000;
// http.listen(PORT, '0.0.0.0', () => {
//   console.log(`✅ Node.js server running on port ${PORT}`);
// });


const express = require('express');
const app = express();
const http = require('http').createServer(app);
const fs = require('fs');
const path = require('path');
const { Client } = require('ssh2');

// 🔧 pingInterval & pingTimeout 늘리기
const io = require('socket.io')(http, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  },
  pingInterval: 10000, // 10초마다 ping
  pingTimeout: 20000   // 20초 안에 pong 없으면 끊음
});

const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 5001 });  // YOLO 서버와 WebSocket 연결 (포트 변경)

// 📹 서버 컴퓨터 접속 정보
const SERVER_CONFIG = {
  host: '192.168.1.39',
  username: 'syu',
  password: 'syucoup',
  // privateKey: require('fs').readFileSync('/path/to/private/key') // SSH 키 사용 시
};

// [수정] 실제 영상 폴더 경로로 변경
const REMOTE_VIDEO_PATH = '/home/syu/detection_video/video/'; // ← 기존: '/home/syu/detection_video/'

// [변경] 네트워크 드라이브 경로 (윈도우에서 Z: 드라이브로 마운트했다고 가정)
const VIDEO_DIR = 'Z:\\'; // 또는 'Z:\\' (윈도우 경로)

// CORS 설정 - 웹에서 API 호출 허용
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});

// CORS 설정 - 웹에서 API 호출 허용
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});

app.use(express.static('public'));
app.use(express.json());

app.get('/', (req, res) => {
  res.send('CCTV Backend Server is running');
});

// [추가] 네트워크 드라이브에서 영상 파일 목록을 읽는 함수
function getLocalVideoList() {
  const fs = require('fs');
  const path = require('path');
  try {
    const files = fs.readdirSync(VIDEO_DIR)
      .filter(file => file.endsWith('.mp4') && file.startsWith('rec-'))
      .map(file => {
        const stat = fs.statSync(path.join(VIDEO_DIR, file));
        return {
          filename: file,
          size: stat.size,
          created: stat.birthtime,
          modified: stat.mtime,
          url: `/videos/${file}`
        };
      })
      .sort((a, b) => b.created - a.created);
    return files;
  } catch (err) {
    console.error('[영상 목록 읽기 오류]', err);
    return [];
  }
}

// [변경] /api/videos 라우트 - 네트워크 드라이브에서 영상 목록 반환
app.get('/api/videos', (req, res) => {
  try {
    const files = getLocalVideoList();
    res.json({ videos: files });
  } catch (error) {
    res.status(500).json({ error: 'Failed to read video directory' });
  }
});

// 📹 영상 파일 스트리밍 - SSH를 통한 원격 파일 스트리밍
// 실제 스트리밍은 별도 구현 필요 (현재는 파일 목록만 조회)
// app.use('/videos', express.static(REMOTE_VIDEO_PATH)); // 로컬 파일이 아니므로 주석 처리

// [추가] /videos/:filename 정적 파일 서빙 (영상 스트리밍)
app.use('/videos', express.static(VIDEO_DIR));

// ✅ WebSocket(YOLO ↔ Node.js)
wss.on('connection', function connection(ws) {
  console.log('[WebSocket] YOLO Server connected');

  let lastSent = {};
  const intervalMs = 100; // 전송 간격 제한 (최대 10fps)

  ws.on('message', function incoming(data) {
    try {
      const parsed = JSON.parse(data.toString());
      const streamName = parsed.stream_name || 'unknown';

      const now = Date.now();
      if (!lastSent[streamName] || now - lastSent[streamName] > intervalMs) {
        lastSent[streamName] = now;
        io.emit(streamName, parsed); // 각 streamName별로 전송
        // console.log(`[WebSocket] Data sent for stream: ${streamName}`);
        // // 필요시 콘솔에 parsed 내용 출력 
        // console.log(`[WebSocket] Data for ${streamName}:`, parsed);
 
        // console.log(parsed);
      }
    } catch (e) {
      console.error('[WebSocket] JSON 처리 실패:', e);
    }
  });

  ws.on('close', () => {
    console.log('[WebSocket] YOLO Server disconnected');
  });

  ws.on('error', (err) => {
    console.error('[WebSocket] Error:', err);
  });
});

// ✅ Socket.IO (Flutter ↔ Node.js)
io.on('connection', (socket) => {
  console.log('[Socket.IO] Flutter client connected');

  socket.on('disconnect', (reason) => {
    console.log(`[Socket.IO] Flutter client disconnected: ${reason}`);
  });

  socket.on('connect_error', (err) => {
    console.error('[Socket.IO] Connect error:', err.message);
  });

  socket.on('connect_timeout', () => {
    console.warn('[Socket.IO] Connect timeout');
  });
});

const PORT = process.env.PORT || 3001; // 포트 변경
http.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Node.js server running on port ${PORT}`);
});
