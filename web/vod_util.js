window.vod_util = {
    define(sign){
        return new TcVod.default({
            getSignature(){
                return sign;
            }
        })
    },
    done(uploader, onDone, onError){
        uploader.done().then(function (result) {
            typeof onDone === 'function' && onDone(result)
        }).catch(function (err) {
            typeof onError === 'function' && onError(err)
        })
    }
}