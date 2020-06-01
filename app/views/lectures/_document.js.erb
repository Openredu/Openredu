  // If absolute URL from the remote server is provided, configure the CORS
  // header on that server.
  var obj = {};
  obj.url = '/getpdf?document_id=<%=lecture.id%>'

  var pdfDoc = null,
    pageNum = 1,
    pageRendering = false,
    pageNumPending = null,
    scale = 0.8,
    canvas = document.getElementById('canvas'),
    ctx = canvas.getContext('2d'),
    widthActual = 600;

  /**
  * Get page info from document, resize canvas accordingly, and render page.
  * @param num Page number.
  */
  function renderPage(num) {
  pageRendering = true;
  // Using promise to fetch the page
  pdfDoc.getPage(num).then(function(page) {

    var viewport = page.getViewport(scale);
    var desiredWidth = widthActual;
    var viewport = page.getViewport(1);
    var scale = desiredWidth / viewport.width;
    var scaledViewport = page.getViewport(scale);
    canvas.height = scaledViewport.height;
    canvas.width = scaledViewport.width;

    // Render PDF page into canvas context
    var renderContext = {
      canvasContext: ctx,
      viewport: scaledViewport
    };
    var renderTask = page.render(renderContext);

    // Wait for rendering to finish
    renderTask.promise.then(function() {
      pageRendering = false;
      if (pageNumPending !== null) {
        // New page rendering is pending
        renderPage(pageNumPending);
        pageNumPending = null;
      }
    });
  });

  // Update page counters
  document.getElementById('page_num').textContent = pageNum;
  }

  /**
  * If another page rendering in progress, waits until the rendering is
  * finised. Otherwise, executes rendering immediately.
  */
  function queueRenderPage(num) {
  if (pageRendering) {
    pageNumPending = num;
  } else {
    renderPage(num);
  }
  }

  /**
  * Displays previous page.
  */
  function onPrevPage() {
  if (pageNum <= 1) {
    return;
  }
  pageNum--;
  queueRenderPage(pageNum);
  }
  document.getElementById('prev').addEventListener('click', onPrevPage);

  /**
  * Displays next page.
  */
  function onNextPage() {
  if (pageNum >= pdfDoc.numPages) {
    return;
  }
  pageNum++;
  queueRenderPage(pageNum);
  }
  document.getElementById('next').addEventListener('click', onNextPage);

  /**
  * Asynchronously downloads PDF.
  */
  PDFJS.getDocument(obj).then(function(pdfDoc_) {
    pdfDoc = pdfDoc_;
    document.getElementById('page_count').textContent = pdfDoc.numPages;

    if(pdfDoc.numPages > 1){
      document.getElementById('pdf-control').style.display = 'block';
    }
    document.getElementById('spinner-pdf').remove();

    renderPage(pageNum);
  });

  function fullScreen(){
      if(canvas.requestFullScreen)
          document.getElementById('view_video').requestFullScreen();
      else if(canvas.webkitRequestFullScreen)
          document.getElementById('view_video').webkitRequestFullScreen();
      else if(canvas.mozRequestFullScreen)
          document.getElementById('view_video').mozRequestFullScreen();
  }
  var fs = false;
  var changeHandler = function(){
    fs = !fs
    if(fs){
      widthActual = window.innerWidth-400
      renderPage(pageNum)
    }else{
      widthActual = 500;
      renderPage(pageNum)
    }
 }

 document.addEventListener("fullscreenchange", changeHandler, false);
 document.addEventListener("webkitfullscreenchange", changeHandler, false);
 document.addEventListener("mozfullscreenchange", changeHandler, false);

  $("#canvas").click(function() {
      fullScreen();
  });
