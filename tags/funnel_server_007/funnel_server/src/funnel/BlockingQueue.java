package funnel;

import java.util.LinkedList;

public class BlockingQueue extends LinkedList {

	public BlockingQueue() {
		super();
	}

	public synchronized void sleep(long msec) { // 指定ミリ秒実行を止めるメソッド
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
