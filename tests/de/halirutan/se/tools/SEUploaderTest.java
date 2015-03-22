package de.halirutan.se.tools;

import junit.framework.Assert;
import org.junit.Test;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.net.URI;

/**
 * @author patrick (11/25/13)
 */
public class SEUploaderTest {

  String imageName = "test.png";
  String failImageName = "notAnImage.txt";

  private static byte[] loadFile(String fileName) throws Exception {
    final URI uri = SEUploaderTest.class.getResource(fileName).toURI();
    File file = new File(uri);
    byte[] data = new byte[(int) file.length()];
    DataInputStream dis = new DataInputStream(new FileInputStream(file));
    dis.readFully(data);
    dis.close();
    return data;
  }

  @Test
  public void testSendImage() throws Exception {
    byte[] imageData = loadFile(imageName);
    final String result = SEUploader.sendImage(imageData);
    System.out.println(result);
    Assert.assertTrue(result.contains("http://i.stack.imgur.com"));
  }

  @Test
  public void testSendImageFail() throws Exception {
    byte[] imageData = loadFile(failImageName);
    final String result = SEUploader.sendImage(imageData);
    System.out.println(result);
    Assert.assertTrue(result.contains("displayUploadError"));
  }
}
