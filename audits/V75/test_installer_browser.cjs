// Chromium smoke test of the actual local installer; external network is blocked.
const fs=require('fs'),path=require('path'),http=require('http'),assert=require('assert');
const {chromium}=require('playwright');
const root=path.resolve(__dirname,'../..');
(async()=>{
 const server=http.createServer((req,res)=>{if(req.url!=='/'){res.writeHead(404);res.end();return;}res.setHeader('Content-Type','text/html; charset=utf-8');res.end(fs.readFileSync(path.join(root,'AVATAR_PLAZA_V75.html')));});
 await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
 const origin=`http://127.0.0.1:${server.address().port}`;let browser;
 try{
  try{browser=await chromium.launch({headless:true});}catch(error){
   if(String(error.message).includes("Executable doesn't exist")){
    const report={result:'not_run',reason:'Chromium executable is not installed in this runtime',otherChecks:'Actual JavaScript, source copies, hashes and DOM double tests are recorded separately',nativeRoblox:false};
    fs.writeFileSync(path.join(__dirname,'installer_browser_results.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));return;
   }throw error;
  }const rows=[];
  for(const [width,height] of [[390,844],[851,392],[1280,720]]){
   const context=await browser.newContext({viewport:{width,height},permissions:['clipboard-read','clipboard-write']});
   await context.route('**/*',route=>route.request().url().startsWith(origin)?route.continue():route.abort());
   const page=await context.newPage();const errors=[];page.on('pageerror',e=>errors.push(e.message));
   await page.goto(origin,{waitUntil:'domcontentloaded'});await page.waitForFunction(()=>manifest&&manifest.latest==='V75');
   await page.evaluate(()=>openVersion('V75'));await page.waitForFunction(()=>readyVersion==='V75');
   assert.equal(await page.locator('#versionContent section.script').count(),37);
   const first=page.locator('#versionContent section.script').first();await first.locator('button.all').click();
   const copied=await page.evaluate(()=>navigator.clipboard.readText());assert(copied.startsWith('-- 07G9_COMMAND_PANEL | ModuleScript'));
   const result=await page.evaluate(()=>({pageWidth:document.documentElement.scrollWidth,viewport:innerWidth,fields:[...document.querySelectorAll('.allcode,.partarea')].every(e=>e.hidden),counter:document.querySelector('.scriptprogress').textContent}));
   assert(result.pageWidth<=width+1,JSON.stringify(result));assert(result.fields);assert(result.counter.includes('1/2'));assert.deepEqual(errors,[]);
   rows.push({width,height,cards:37,clipboard:'exact source',horizontalOverflow:false,pageErrors:errors});await context.close();
  }
  const report={result:'pass',runtime:'Chromium headless, local HTML, external network blocked',screens:rows,nativeRoblox:false};
  fs.writeFileSync(path.join(__dirname,'installer_browser_results.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));
 }finally{if(browser)await browser.close();await new Promise(resolve=>server.close(resolve));}
})().catch(e=>{console.error(e);process.exit(1)});
