import io, json, tempfile, threading, unittest, urllib.request, urllib.error
from http.server import ThreadingHTTPServer
from pathlib import Path
from unittest.mock import patch
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import server
class FakeProcess:
 def __init__(self,*args,**kw): self.stdin=io.StringIO(); self.args=args
 def poll(self): return 0
 def wait(self): return 0
class BatchTest(unittest.TestCase):
 def test_one_click_handoff_without_submitting(self):
  with tempfile.TemporaryDirectory() as tmp:
   server.ROOT=Path(tmp);server.BATCHES=server.ROOT/'batches';server.STORE=server.ROOT/'data.json';server.ACTIVE=None
   resume=server.ROOT/'resume.pdf';resume.write_text('fixture');server.STORE.write_text(json.dumps({'applications':[], 'profile':{'resume':str(resume),'portfolio':'https://example.com'}}))
   http=ThreadingHTTPServer(('127.0.0.1',0),server.Handler);server.PORT=http.server_address[1]
   threading.Thread(target=http.serve_forever,daemon=True).start()
   base=f'http://127.0.0.1:{server.PORT}'; jobs=[{'id':'test','title':'Test','company':'Fixture','url':'https://remotive.com/remote-jobs/test/fixture'}]
   def send(token):
    req=urllib.request.Request(base+'/api/batch',data=json.dumps({'jobs':jobs}).encode(),headers={'Origin':base,'Content-Type':'application/json','X-Career-Token':token})
    return urllib.request.urlopen(req)
   with self.assertRaises(urllib.error.HTTPError) as e:send('wrong')
   self.assertEqual(e.exception.code,403)
   with patch.object(server,'worker_running',return_value=False), patch.object(server.subprocess,'Popen',FakeProcess):
    response=json.load(send(server.TOKEN));self.assertEqual(response['status'],'started')
   with patch.object(server,'worker_running',return_value=False): status=json.load(urllib.request.urlopen(base+'/api/batch/status'))
   self.assertEqual(status['batches'][0]['jobs'],jobs);self.assertIsNone(status['batches'][0]['result'])
   self.assertIn('codex',server.ACTIVE.args[0][0]);http.shutdown();http.server_close()
if __name__=='__main__':unittest.main()
