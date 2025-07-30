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

// 📹 라즈베리파이 CCTV 연결 설정
const RASPBERRY_PI_CONFIG = {
  host: '192.168.1.11', // 라즈베리파이 IP 주소
  port: 5000, // 라즈베리파이 WebSocket 포트
};

// 📹 서버 컴퓨터 접속 정보
const SERVER_CONFIG = {
  host: '192.168.1.39',
  username: 'syu',
  password: 'syucoup',
  // privateKey: require('fs').readFileSync('/path/to/private/key') // SSH 키 사용 시
};

// 📹 SSH를 통한 원격 파일 접근 설정
const SSH_CONFIG = {
  host: '192.168.1.39',
  username: 'syu',
  password: 'syucomp',
  // privateKey: require('fs').readFileSync('/path/to/private/key') // SSH 키 사용 시
};

// 📹 원격 서버의 영상 폴더 경로
const REMOTE_VIDEO_PATH = '/home/syu/detection_video/video/';

// 📹 SSH를 통한 원격 파일 목록 조회 함수
function getRemoteVideoList(relPath = '') {
  return new Promise((resolve, reject) => {
    const conn = new Client();
    
    conn.on('ready', () => {
      console.log('[SSH] 연결 성공');
      
      // Linux 경로이므로 path.join 대신 직접 조합
      const remotePath = REMOTE_VIDEO_PATH + relPath;
      console.log(`[SSH] 원격 경로: ${remotePath}`);
      
      conn.exec(`ls -la "${remotePath}"`, (err, stream) => {
        if (err) {
          console.error('[SSH] 명령어 실행 오류:', err);
          conn.end();
          reject(err);
          return;
        }
        
        let data = '';
        stream.on('data', (chunk) => {
          data += chunk;
        });
        
        stream.on('close', () => {
          conn.end();
          
          try {
            const lines = data.trim().split('\n').slice(1); // 첫 번째 줄(총합) 제외
            const items = [];
            
            for (const line of lines) {
              const parts = line.split(/\s+/);
              if (parts.length >= 9) {
                const permissions = parts[0];
                const isDirectory = permissions.startsWith('d');
                const name = parts[8];
                
                if (isDirectory) {
                  items.push({ name, type: 'directory' });
                                 } else if (name.endsWith('.mp4')) {
                   const size = parseInt(parts[4]) || 0;
                   items.push({
                     name,
                     type: 'file',
                     size,
                     url: `/videos/${relPath || 'root'}/${name}`
                   });
                 }
              }
            }
            
            console.log(`[SSH] 원격 파일 목록 조회 완료: ${items.length}개 항목`);
            resolve(items);
          } catch (error) {
            console.error('[SSH] 파일 목록 파싱 오류:', error);
            reject(error);
          }
        });
      });
    });
    
    conn.on('error', (err) => {
      console.error('[SSH] 연결 오류:', err);
      console.error('[SSH] 연결 설정:', SSH_CONFIG);
      reject(err);
    });
    
    conn.on('timeout', () => {
      console.error('[SSH] 연결 타임아웃');
      reject(new Error('SSH 연결 타임아웃'));
    });
    
    console.log('[SSH] 연결 시도:', SSH_CONFIG.host);
    conn.connect(SSH_CONFIG);
  });
}

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
  try {
    const files = fs.readdirSync(VIDEO_DIR);
    console.log('[API 호출] Z: 드라이브 파일 목록:', files); // 추가
    const filtered = files.filter(file => file.endsWith('.mp4') && file.startsWith('rec-'));
    console.log('[API 호출] 필터링된 파일 목록:', filtered); // 추가
    return filtered
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
  } catch (err) {
    console.error('[영상 목록 읽기 오류]', err);
    return [];
  }
}

// 📹 SSH를 통한 원격 파일 목록 조회 API
app.get('/api/videos', async (req, res) => {
  const relPath = req.query.path || '';
  const offset = parseInt(req.query.offset || '0', 10);
  const limit = parseInt(req.query.limit || '100', 10);

  try {
    console.log(`[API] SSH를 통한 원격 파일 목록 조회: ${relPath}`);
    const items = await getRemoteVideoList(relPath);
    
    // 폴더는 항상 모두 반환
    const folders = items.filter(item => item.type === 'directory');
    
    // 파일은 offset/limit 적용
    const files = items
      .filter(item => item.type === 'file')
      .slice(offset, offset + limit);
    
    const result = [...folders, ...files];
    console.log(`[API] 조회 결과: 폴더 ${folders.length}개, 파일 ${files.length}개`);
    res.json({ videos: result });
  } catch (err) {
    console.error('[API] SSH 파일 목록 조회 오류:', err);
    res.status(500).json({ error: '원격 서버에서 파일 목록을 읽을 수 없습니다.' });
  }
});

// 📹 영상 파일 스트리밍 - SSH를 통한 원격 파일 스트리밍
// 실제 스트리밍은 별도 구현 필요 (현재는 파일 목록만 조회)
// app.use('/videos', express.static(REMOTE_VIDEO_PATH)); // 로컬 파일이 아니므로 주석 처리

// 📹 SSH를 통한 원격 파일 스트리밍 (Range 요청 지원)
app.get('/videos/:path/:filename', async (req, res) => {
  const subPath = req.params.path;
  const filename = req.params.filename;
  const remotePath = `${REMOTE_VIDEO_PATH}${subPath}/${filename}`;
  
  console.log(`[SSH] 파일 스트리밍 요청: ${subPath}/${filename}`);
  
  try {
    const conn = new Client();
    
    conn.on('ready', () => {
      console.log(`[SSH] 파일 스트리밍 연결 성공: ${subPath}/${filename}`);
      
      // 파일 정보 확인 (존재여부, 크기, 타입)
      conn.exec(`file "${remotePath}" && stat -c%s "${remotePath}"`, (err, stream) => {
        if (err) {
          console.error('[SSH] 파일 정보 확인 오류:', err);
          conn.end();
          res.status(404).send('파일을 찾을 수 없습니다.');
          return;
        }
        
        let output = '';
        stream.on('data', (data) => {
          output += data.toString();
        });
        
        stream.on('close', () => {
          const lines = output.trim().split('\n');
          if (lines.length < 2) {
            conn.end();
            res.status(404).send('파일을 찾을 수 없습니다.');
            return;
          }
          
          const fileInfo = lines[0];
          const fileSize = parseInt(lines[1]);
          
          console.log(`[SSH] 파일 정보: ${fileInfo}`);
          console.log(`[SSH] 파일 크기: ${fileSize} bytes`);
          
          // Range 요청 처리
          const range = req.headers.range;
          if (range) {
            const parts = range.replace(/bytes=/, "").split("-");
            const start = parseInt(parts[0], 10);
            const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
            const chunksize = (end - start) + 1;
            
            console.log(`[SSH] Range 요청: ${start}-${end}/${fileSize}`);
            
            res.writeHead(206, {
              'Content-Range': `bytes ${start}-${end}/${fileSize}`,
              'Accept-Ranges': 'bytes',
              'Content-Length': chunksize,
              'Content-Type': 'video/mp4',
              'Access-Control-Allow-Origin': '*'
            });
            
            // dd 명령어로 특정 범위 읽기
            conn.exec(`dd if="${remotePath}" bs=1 skip=${start} count=${chunksize} 2>/dev/null`, (err, stream) => {
              if (err) {
                console.error('[SSH] Range 읽기 오류:', err);
                conn.end();
                res.status(500).send('파일을 읽을 수 없습니다.');
                return;
              }
              
              stream.pipe(res);
              stream.on('close', () => {
                conn.end();
                console.log(`[SSH] Range 스트리밍 완료: ${start}-${end}`);
              });
            });
          } else {
            // 전체 파일 스트리밍
            res.writeHead(200, {
              'Content-Length': fileSize,
              'Content-Type': 'video/mp4',
              'Accept-Ranges': 'bytes',
              'Access-Control-Allow-Origin': '*'
            });
            
            conn.exec(`cat "${remotePath}"`, (err, stream) => {
              if (err) {
                console.error('[SSH] 파일 읽기 명령 오류:', err);
                conn.end();
                res.status(500).send('파일을 읽을 수 없습니다.');
                return;
              }
              
              stream.pipe(res);
              stream.on('close', () => {
                conn.end();
                console.log(`[SSH] 전체 파일 스트리밍 완료: ${fileSize} bytes`);
              });
            });
          }
        });
      });
    });
    
    conn.on('error', (err) => {
      console.error('[SSH] 파일 스트리밍 연결 오류:', err);
      res.status(500).send('원격 서버에 연결할 수 없습니다.');
    });
    
    conn.connect(SSH_CONFIG);
  } catch (error) {
    console.error('[SSH] 파일 스트리밍 오류:', error);
    res.status(500).send('파일 스트리밍 중 오류가 발생했습니다.');
  }
});

// 📹 라즈베리파이 CCTV 연결
let raspberryPiWs = null;

function connectToRaspberryPi() {
  try {
    console.log(`[라즈베리파이] 연결 시도: ${RASPBERRY_PI_CONFIG.host}:${RASPBERRY_PI_CONFIG.port}`);
    raspberryPiWs = new WebSocket(`ws://${RASPBERRY_PI_CONFIG.host}:${RASPBERRY_PI_CONFIG.port}`);

    raspberryPiWs.on('open', () => {
      console.log('[라즈베리파이] 연결 성공!');
    });

    raspberryPiWs.on('message', (data) => {
      try {
        console.log('[라즈베리파이] 원시 데이터 수신:', data.toString().substring(0, 100) + '...');
        
        // JSON 데이터 파싱
        const jsonData = JSON.parse(data.toString());
        console.log('[라즈베리파이] 파싱된 데이터 키:', Object.keys(jsonData));
        
        // 라즈베리파이에서 받은 영상 데이터와 탐지 결과를 stream1으로 전송
        const streamData = {
          stream_name: 'stream1',
          image: jsonData.image,
          detections: jsonData.detections || [] // YOLO 탐지 결과
        };
        
        io.emit('stream1', streamData);
        console.log(`[라즈베리파이] 영상 데이터 전송됨 (탐지된 객체: ${streamData.detections.length}개)`);
      } catch (error) {
        console.error('[라즈베리파이] 데이터 처리 오류:', error);
        console.error('[라즈베리파이] 원시 데이터:', data.toString().substring(0, 200));
      }
    });

    raspberryPiWs.on('close', () => {
      console.log('[라즈베리파이] 연결 끊어짐. 5초 후 재연결...');
      setTimeout(connectToRaspberryPi, 5000);
    });

    raspberryPiWs.on('error', (error) => {
      console.error('[라즈베리파이] 연결 오류:', error);
    });
  } catch (error) {
    console.error('[라즈베리파이] 연결 실패:', error);
    setTimeout(connectToRaspberryPi, 5000);
  }
}

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
  console.log(`🌐 Web interface: http://localhost:${PORT}`);
  console.log(`📹 Raspberry Pi connection: ws://${RASPBERRY_PI_CONFIG.host}:${RASPBERRY_PI_CONFIG.port}`);
  
  // 서버 시작 시 라즈베리파이 연결 시도
  connectToRaspberryPi();
});

// 파일명 파싱 정확도 측정용 엔드포인트
app.get('/api/parse-test', async (req, res) => {
  // 실제 파일 목록 가져오기 (예: 1번 폴더)
  const items = await getRemoteVideoList('1');
  const regex = /^rec-\d{5}\.mp4$/;
  let success = 0, fail = 0;
  const details = [];

  for (const item of items) {
    if (item.type === 'file') {
      const result = regex.test(item.name);
      if (result) success++;
      else fail++;
      details.push({ name: item.name, success: result });
    }
  }

  res.json({
    total: success + fail,
    success,
    fail,
    successRate: ((success / (success + fail)) * 100).toFixed(1) + '%',
    details: details.slice(0, 20) // 일부만 예시로 반환
  });
});
