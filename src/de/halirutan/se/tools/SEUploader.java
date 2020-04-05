package de.halirutan.se.tools;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

/**
 * Provides a method to send PNG image bytes to a dedicated imgur.com server for Stack Exchange/Overflow.
 *
 * It works by first retrieving a key from Stack Exchange that needs to be included when sending the image.
 * Then, it creates a temporary file from the PNG bytes and sends everything to Stack Overflow.
 * On success, we get the URL of the uploaded image that we turn into paste-ready Markdown code in Mathematica.
 *
 * @author Patrick Scheibe (4/9/13)
 */
public class SEUploader {

    public static final String SO_URL = "https://stackoverflow.com/upload/image?method=json?https=true";
    public static final String SE_URL = "https://stackexchange.com";

    private static final Pattern F_KEY_PATTERN = Pattern.compile("\\s*fkey:\\s*'([0-9a-z]+)'.*");

    public static String sendImage(byte[] imgPngContent) throws SEUploaderException {
        String fKey = getFKey();
        try {
            File tmpFile = File.createTempFile("image", ".png");
            tmpFile.deleteOnExit();
            InputStream in = new ByteArrayInputStream(imgPngContent);
            FileOutputStream out = new FileOutputStream(tmpFile);
            org.apache.commons.io.IOUtils.copy(in, out);

            URL url = new URL(SO_URL);
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(url.toURI());

            MultipartEntity entity = new MultipartEntity(HttpMultipartMode.BROWSER_COMPATIBLE);
            entity.addPart("file", new FileBody(tmpFile, "image/png"));
            entity.addPart("fkey", new StringBody(fKey));
            httpPost.setEntity(entity);

            final HttpResponse response = httpClient.execute(httpPost);

            return EntityUtils.toString(response.getEntity());
        } catch (Throwable e) {
            throw new SEUploaderException(e.getMessage());
        }
    }

    /**
     * Retrieves an fkey used against cross-site request forgery attacks. The key is necessary to upload an image.
     * Please see https://meta.stackexchange.com/q/74154/178346 for more information.
     *
     * @return fkey if it could be found
     * @throws SEUploaderException in case io or retrieval went wrong
     */
    public static String getFKey() throws SEUploaderException {
        try {
            URL seUrl = new URL(SE_URL);

            BufferedReader reader = new BufferedReader(new InputStreamReader(seUrl.openStream()));
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.contains("fkey")) {
                    final Matcher matcher = F_KEY_PATTERN.matcher(line);
                    if (matcher.matches()) {
                        reader.close();
                        return matcher.group(1);
                    }
                }
            }
            reader.close();
            throw new SEUploaderException("Could not retrieve FKey from StackExchange. " +
                    "This key is necessary to upload images.");
        } catch (MalformedURLException e) {
            throw new SEUploaderException("StackExchange URL is malformed. This should never happen.");
        } catch (IOException e) {
            throw new SEUploaderException("IO Exception during reading StackExchange's source");
        }
    }
}
