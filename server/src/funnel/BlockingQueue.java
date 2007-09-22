package funnel;

import java.util.LinkedList;

public class BlockingQueue extends LinkedList {

	/**
	 * Generated serialVersionUID
	 */
	private static final long serialVersionUID = 7156118094416432414L;

	public BlockingQueue() {
		super();
	}

	public synchronized void sleep(long msec) {
		try {
			wait(msec);
		} catch (InterruptedException e) {
		}
	}

	public boolean push(Object o) {
		return this.add(o);
	}

	public Object pop(int timeout) {
		int counter = 0;

		while (this.size() < 1) {
			this.sleep(1);
			counter++;
			if (counter >= timeout) {
				// throw new RuntimeException("timeout");
				return null;
			}
			// DO THROW TIMEOUT EXCEPTION HERE!!!
		}

		return this.removeFirst();
	}
}
