
/**
 * 防抖函数
 * @param {*} fn 要执行的函数
 * @param {*} delay 间隔时间
 * @returns function
 */
export function debounce(fn: { apply: (arg0: any, arg1: any) => void; }, delay: number | undefined) {
  let timer: number;
  return function (this:any, ...args: any) {
    if (timer > 0) {
      clearTimeout(timer);
    }
    timer = window.setTimeout(() => {
      fn.apply(this, args);
      timer = -1;
    }, delay);
  };
}

/**
 * 节流函数
 * @param {*} fn 要执行的函数
 * @param {*} delay 间隔时间
 * @returns function
 */
export function throttle(fn: { apply: (arg0: any, arg1: any[]) => void; }, delay: number) {
  let previousTime = 0;
  return function (this:any, ...args: any[]) {
    // eslint-disable-next-line prefer-rest-params
    const now  = Date.now();
    if (now - previousTime > delay) {
      fn.apply(this, args);
      previousTime = now;
    }
  };
};

/**
 * 将 dom 元素全屏
 * @param {dom} element dom元素
 * @example
 * setFullscreen(document.documentElement) // 整个页面进入全屏
 * setFullscreen(document.getElementById("id")) // 某个元素进入全屏
 */
export function setFullScreen(element: HTMLElement) {
  const fullScreenElement = element as HTMLElement & {
    mozRequestFullScreen(): Promise<void>;
    webkitRequestFullscreen(): Promise<void>;
    msRequestFullscreen(): Promise<void>;
  };
  if (fullScreenElement.requestFullscreen) {
    fullScreenElement.requestFullscreen();
  } else if (fullScreenElement.mozRequestFullScreen) {
    fullScreenElement.mozRequestFullScreen();
  } else if (fullScreenElement.msRequestFullscreen) {
    fullScreenElement.msRequestFullscreen();
  } else if (fullScreenElement.msRequestFullscreen) {
    fullScreenElement.msRequestFullscreen();
  }
}

/**
 * 退出全屏
 * @example
 * exitFullscreen();
 */
export function exitFullScreen() {
  if (!document.fullscreenElement) {
    return;
  }
  const exitFullScreenDocument  = document as Document & {
    mozCancelFullScreen(): Promise<void>;
    webkitExitFullscreen(): Promise<void>;
    msExitFullscreen(): Promise<void>;
  };
  if (exitFullScreenDocument.exitFullscreen) {
    exitFullScreenDocument.exitFullscreen();
  } else if (exitFullScreenDocument.msExitFullscreen) {
    exitFullScreenDocument.msExitFullscreen();
  } else if (exitFullScreenDocument.mozCancelFullScreen) {
    exitFullScreenDocument.mozCancelFullScreen();
  } else if (exitFullScreenDocument.webkitExitFullscreen) {
    exitFullScreenDocument.webkitExitFullscreen();
  }
}
