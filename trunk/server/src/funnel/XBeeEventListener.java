package funnel;

public interface XBeeEventListener {
	void rxPacketEvent(int source, int rssi, int options, int[] data);

	void rxIOStatusEvent(int source, int rssi, float[] inputData);

	void networkingIdentificationEvent(int my, int sh, int sl, int db, String ni);

	void firmwareVersionEvent(String version);

	void sourceAddressEvent(String sourceAddress);

	void panIdEvent(String panId);

	void txStatusMessageEvent(int status);

	void modemStatusEvent(int status);

	void unsupportedApiEvent(String apiIdentifier);
}
