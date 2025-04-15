export class ApplyUploadUGCReply {
  code: number;
  message: string;
  data: ApplyUploadUGCData;

  constructor(data: ApplyUploadUGCData, code: number, message: string) {
    this.data = data;
    this.code = code;
    this.message = message;
  }
}

export class ApplyUploadUGCData {
  video: ApplyUploadUGCVideo;
  cover: ApplyUploadUGCCover;
  storageAppId: number;
  storageBucket: string;
  storageRegionV5: string;
  vodSessionKey: string;
  tempCertificate: ApplyUploadUGCCertificate;

  constructor(video: ApplyUploadUGCVideo, cover: ApplyUploadUGCCover, storageAppId: number, storageBucket: string,
    storageRegionV5: string,
    vodSessionKey: string,
    tempCertificate: ApplyUploadUGCCertificate) {
    this.video = video;
    this.cover = cover;
    this.storageAppId = storageAppId;
    this.storageBucket = storageBucket;
    this.storageRegionV5 = storageRegionV5;
    this.vodSessionKey = vodSessionKey;
    this.tempCertificate = tempCertificate;
  }
}

export class ApplyUploadUGCVideo {
  storageSignature: string;
  storagePath: string;

  constructor(storageSignature: string, storagePath: string) {
    this.storageSignature = storageSignature;
    this.storagePath = storagePath;
  }
}

export class ApplyUploadUGCCover {
  storagePath: string;

  constructor(storagePath: string) {
    this.storagePath = storagePath;
  }
}

export class ApplyUploadUGCCertificate {
  secretId: string;
  secretKey: string;
  token: string;
  expiredTime: number;

  constructor(secretId: string, secretKey: string, token: string, expiredTime: number) {
    this.secretId = secretId;
    this.secretKey = secretKey;
    this.token = token;
    this.expiredTime = expiredTime;
  }
}

export class CommitUploadUGCReply {
  code: number;
  message: string;
  data: CommitUploadUGCCData;

  constructor(data: CommitUploadUGCCData, code: number, message: string) {
    this.data = data;
    this.code = code;
    this.message = message;
  }
}

export class CommitUploadUGCCData {
  video: CommitUploadUGCVideo;
  cover: CommitUploadUGCover;
  fileId: string;

  constructor(video: CommitUploadUGCVideo, cover: CommitUploadUGCover, fileId: string) {
    this.video = video;
    this.cover = cover;
    this.fileId = fileId;
  }
}

export class CommitUploadUGCVideo {
  url: string;

  constructor(url: string) {
    this.url = url;
  }
}

export class CommitUploadUGCover {
  url: string;

  constructor(url: string) {
    this.url = url;
  }
}
