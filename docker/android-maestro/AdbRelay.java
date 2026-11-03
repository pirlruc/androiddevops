import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;

/** Relays 127.0.0.1:5037 to ADB_SERVER_SOCKET (tcp:host:port). */
public final class AdbRelay {
    private AdbRelay() {}

    public static void main(String[] args) throws Exception {
        String spec = System.getenv("ADB_SERVER_SOCKET");
        if (spec == null || !spec.startsWith("tcp:")) {
            return;
        }
        String rest = spec.substring(4);
        int colon = rest.lastIndexOf(':');
        String host = rest.substring(0, colon);
        int port = Integer.parseInt(rest.substring(colon + 1));
        // adb is a local plaintext protocol. The listen socket is loopback only.
        // nosemgrep: java.lang.security.audit.crypto.unencrypted-socket.unencrypted-socket
        ServerSocket server = new ServerSocket(5037, 50, InetAddress.getByName("127.0.0.1"));
        while (true) {
            Socket incoming = server.accept();
            Thread worker = new Thread(() -> bridge(incoming, host, port));
            worker.setDaemon(true);
            worker.start();
        }
    }

    private static void bridge(Socket incoming, String host, int port) {
        // nosemgrep: java.lang.security.audit.crypto.unencrypted-socket.unencrypted-socket
        try (Socket upstream = new Socket(host, port)) {
            Thread outbound = new Thread(() -> copy(incoming, upstream));
            outbound.setDaemon(true);
            outbound.start();
            copy(upstream, incoming);
        } catch (IOException ignored) {
            // The client closed the connection.
        } finally {
            try {
                incoming.close();
            } catch (IOException ignored) {
                // Already closed.
            }
        }
    }

    private static void copy(Socket from, Socket to) {
        try {
            InputStream in = from.getInputStream();
            OutputStream out = to.getOutputStream();
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) >= 0) {
                out.write(buf, 0, n);
                out.flush();
            }
        } catch (IOException ignored) {
            // The other side hung up.
        }
        try {
            to.shutdownOutput();
        } catch (IOException ignored) {
            // The socket is already closed.
        }
    }
}
