package funnel;

public class PortRange {
	private int min = 0;
	private int max = 0;
	private int counts = 0;

	public PortRange() {
	}

	public boolean contains(int value) {
		return (min <= value) && (value <= max);
	}

	/**
	 * @return the min
	 */
	public int getMin() {
		return min;
	}

	/**
	 * @return the max
	 */
	public int getMax() {
		return max;
	}

	/**
	 * @return the counts
	 */
	public int getCounts() {
		return counts;
	}

	/**
	 * @param min
	 *            the minimum value to set
	 * @param max
	 *            the maximum value to set
	 */
	public void setRange(int min, int max) {
		this.min = min;
		this.max = max;
		if (this.min > this.max) {
			this.max = this.min;
		}
		if (this.max == this.min) {
			this.counts = 0;
		} else {
			this.counts = max - min + 1;
		}
	}
}
