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

const REMOTE_VIDEO_PATH = '/home/syu/detection_video/';

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

// 📹 SSH를 통한 원격 파일 목록 조회
function getRemoteVideoList() {
  return new Promise((resolve, reject) => {
    const conn = new Client();

    conn.on('ready', () => {
      console.log('SSH connection established');

      // 원격 디렉토리의 파일 목록 조회
      conn.exec(`find ${REMOTE_VIDEO_PATH} -name "recv_*.mp4" -type f -exec stat -c "%n|%s|%Y" {} \\;`, (err, stream) => {
        if (err) {
          conn.end();
          return reject(err);
        }

        let output = '';
        stream.on('data', (data) => {
          output += data.toString();
        });

        stream.on('close', () => {
          conn.end();

          try {
            const files = output.trim().split('\n')
              .filter(line => line.length > 0)
              .map(line => {
                const [fullPath, size, mtime] = line.split('|');
                const filename = path.basename(fullPath);
                const modifiedDate = new Date(parseInt(mtime) * 1000);

                return {
                  filename: filename,
                  size: parseInt(size),
                  created: modifiedDate,
                  modified: modifiedDate,
                  url: `/videos/${filename}`
                };
              })
              .sort((a, b) => new Date(b.created) - new Date(a.created));

            resolve(files);
          } catch (parseError) {
            reject(parseError);
          }
        });
      });
    });

    conn.on('error', (err) => {
      reject(err);
    });

    conn.connect(SERVER_CONFIG);
  });
}

// 📹 영상 목록 조회 API - SSH를 통한 원격 접근
app.get('/api/videos', async (req, res) => {
  try {
    const files = await getRemoteVideoList();
    res.json({ videos: files });
  } catch (error) {
    console.error('Error reading remote video directory:', error);

    // SSH 연결 실패 시 임시 테스트 데이터 반환
    const testFiles = [
      {
        filename: 'recv_20250626_143000.mp4',
        size: 15728640,
        created: new Date('2025-06-26T14:30:00'),
        modified: new Date('2025-06-26T14:30:00'),
        url: '/videos/recv_20250626_143000.mp4'
      },
      {
        filename: 'recv_20250626_120000.mp4',
        size: 25165824,
        created: new Date('2025-06-26T12:00:00'),
        modified: new Date('2025-06-26T12:00:00'),
        url: '/videos/recv_20250626_120000.mp4'
      }
    ];

    console.log('SSH 연결 실패 - 테스트 데이터 반환');
    res.json({ videos: testFiles });
  }
});

// 📹 영상 파일 스트리밍 - SSH를 통한 원격 파일 스트리밍
// 실제 스트리밍은 별도 구현 필요 (현재는 파일 목록만 조회)
// app.use('/videos', express.static(REMOTE_VIDEO_PATH)); // 로컬 파일이 아니므로 주석 처리

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
