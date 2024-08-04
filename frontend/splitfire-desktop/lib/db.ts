import Dexie, { Table } from "dexie";
import { Mode, ModeDemucs } from "../app/_src/components/player/models/Mode";
import User from "../models/user";
import { AudioFile } from "../app/_src/components/player/models/AudioFile";
import axios from "../app/_src/lib/axios";
import { Result } from "../app/_src/components/player/models/Result";
import { Logger } from "tslog";
import isTauri from "../app/_src/lib/isTauri";

// Legacy Spleeter result file
export interface AudioFiles {
  id?: number;
  audioFileId: string;
  type: Mode;
  file: Blob;
}

export enum CurrentUserType {
  MAIN,
  GUEST,
}

export interface CurrentUser {
  accessToken: string;
  type: CurrentUserType;
  mode: Mode;
  user: User;
}

// Splitfire result file
interface ResultFile {
  id?: number;
  audioFileId: number;
  type: ModeDemucs;
  buffer: ArrayBuffer;
  blobType: string;
}

export interface BlobFile {
  file: Blob;
  mode: ModeDemucs;
}

export class SplitfireDB extends Dexie {
  audioFiles!: Table<AudioFiles>;
  resultFiles!: Table<ResultFile>;
  currentUser!: Table<CurrentUser>;

  log = new Logger({
    name: "SplitfireDB",
    type: isTauri() ? "json" : "pretty",
  });

  constructor() {
    super("splitfireDB");
    this.version(10).stores({
      audioFiles: "++id, [audioFileId+type]", // This is when I was using Spleeter
      resultFiles: "++id, [audioFileId+type]", // This is when I was using Demucs
      currentUser: "++id, [userId+type], type",
    });
  }

  // The public interface to get the blob result files.
  // It takes the audio file and then compute the modes from the results field.
  async getResultFiles(audioFile: AudioFile): Promise<BlobFile[]> {
    return new Promise(async (resolve, reject) => {
      try {
        // Check modes of results
        const modes: ModeDemucs[] = audioFile.results.map(
          (result) => result.filename.split("-").shift() as ModeDemucs
        );

        this.log.error("modes", modes);
        let resultFiles: BlobFile[] = [];
        // Check if we have result file in the db
        for (const mode of modes) {
          const result = await this._getResultFile(audioFile, mode);
          resultFiles.push(result);
        }
        this.log.debug("resultFiles", resultFiles);
        resolve(resultFiles);
      } catch (error) {
        this.log.error(error);
        reject(error);
      }
    });
  }

  async _getResultFile(
    audioFile: AudioFile,
    mode: ModeDemucs
  ): Promise<BlobFile> {
    return new Promise(async (resolve, reject) => {
      try {
        // Check if we have result file in the db
        const result = await db.resultFiles.get({
          audioFileId: audioFile.id,
          type: mode,
        });
        // if we do, then return it
        this.log.debug("_getResultFile", result);
        if (result?.buffer) {
          const blob = new Blob([result.buffer], { type: result.blobType });
          resolve({ file: blob, mode });
        } else {
          // otherwise, download the file and return it
          const file = await this._downloadFile(audioFile, mode);
          resolve({ file, mode });
        }
      } catch (error) {
        reject(error);
      }
    });
  }

  async _downloadFile(audioFile: AudioFile, type: ModeDemucs): Promise<Blob> {
    this.log.debug("_downloadFile", type);
    let result: Result | undefined;
    switch (type) {
      case ModeDemucs.Vocals:
        result = audioFile.results.find((obj) => {
          return obj.filename.startsWith("vocals");
        });
        break;
      case ModeDemucs.Bass:
        result = audioFile?.results.find((obj) => {
          return obj.filename.startsWith("bass");
        });
        break;
      case ModeDemucs.Drums:
        result = audioFile?.results.find((obj) => {
          return obj.filename.startsWith("drums");
        });
        break;
      case ModeDemucs.Other:
        result = audioFile?.results.find((obj) => {
          return obj.filename.startsWith("other");
        });
        break;
    }

    this.log.debug("Download url", result?.source_file);

    return new Promise(async (resolve, reject) => {
      try {
        const response = await axios({
          url: result?.source_file,
          method: "GET",
          responseType: "blob",
        });
        const blob = new Blob([response.data], { type: "audio/mp3" });
        const buffer = await blob.arrayBuffer();
        const item: ResultFile = {
          audioFileId: audioFile.id,
          type: type,
          buffer: buffer,
          blobType: blob.type,
        };
        db.resultFiles.add(item);
        resolve(blob);
      } catch (error) {
        this.log.error(error);
        reject(error);
      }
    });
  }
}

export const db = new SplitfireDB();
