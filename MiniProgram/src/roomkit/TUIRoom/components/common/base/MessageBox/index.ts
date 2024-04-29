function TUIMessageBox(params ?: {
  message?: string,
  title?: string,
  confirmButtonText?: string;
  cancelButtonText?: string;
  callback?: any;
}) {
  const { confirmButtonText = '确定', cancelButtonText = '取消', callback } = params || {};
  uni.showModal({
    title: params?.title,
    content: params?.message,
    confirmText: confirmButtonText,
    cancelText: cancelButtonText,
    success: callback,
    fail: () => {
      throw Error('user cancel');
    },
  });
}

export default TUIMessageBox;
