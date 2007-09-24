package funnel;

import java.io.IOException;
import java.net.Socket;

public class NotificationPortClient extends Client {

	public NotificationPortClient(Server server, Socket socket)
			throws IOException {
		super(server, socket);
	}

}
