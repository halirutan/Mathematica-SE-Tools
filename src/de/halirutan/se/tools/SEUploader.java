package de.halirutan.se.tools;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

/**
 * @author patrick (4/9/13)
 */
@SuppressWarnings("UnusedDeclaration")
public class SEUploader {

  public static final String URL = "https://stackoverflow.com/upload/image";

  public static String sendImage(byte[] imgPngContent) throws SEUploaderException {
    try {
      File tmpFile = File.createTempFile("image", "png");
      tmpFile.deleteOnExit();
      InputStream in = new ByteArrayInputStream(imgPngContent);
      FileOutputStream out = new FileOutputStream(tmpFile);
      org.apache.commons.io.IOUtils.copy(in, out);

      MultipartEntity entity = new MultipartEntity(HttpMultipartMode.BROWSER_COMPATIBLE);
      entity.addPart("source", new StringBody("computer"));
      entity.addPart("filename", new FileBody(tmpFile, "image/png"));
      HttpPost httpPost = new HttpPost(URL);
      httpPost.setEntity(entity);
      HttpClient httpClient = new DefaultHttpClient();

      final HttpResponse response = httpClient.execute(httpPost);

      return EntityUtils.toString(response.getEntity());

    } catch (Throwable e) {
      throw new SEUploaderException(e.getMessage());
    }
  }

}
