package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import java.util.Arrays;
import java.util.List;
import org.eclipse.xtext.xbase.lib.Conversions;

/**
 * Statistics holding records of the last N operations (success or error). The amount
 * of errors can be reached via method {@link ErrorStatistics#errors() errors()}.<br>
 * Internally an array is used to track successful and erroneous operations in the manner
 * of a cyclic-buffer. This class is immutable, so the array is copied if the array actually changes.
 */
@SuppressWarnings("all")
class ErrorRateStatistics {
  private final boolean[] data;
  
  private final int errors;
  
  private final int index;
  
  /**
   * @param size amount of sampled results (success/error)
   */
  public ErrorRateStatistics(final int size) {
    boolean[] _newBooleanArrayOfSize = new boolean[size];
    this.data = _newBooleanArrayOfSize;
    Arrays.fill(this.data, true);
    this.errors = 0;
    this.index = 0;
  }
  
  private ErrorRateStatistics(final int errors, final int index, final boolean[] data) {
    this.errors = errors;
    this.index = index;
    this.data = data;
  }
  
  public ErrorRateStatistics addError() {
    return this.updateFiledAtCurrentIndexTo(false);
  }
  
  public ErrorRateStatistics addSuccess() {
    return this.updateFiledAtCurrentIndexTo(true);
  }
  
  public ErrorRateStatistics updateFiledAtCurrentIndexTo(final boolean newValue) {
    ErrorRateStatistics _xblockexpression = null;
    {
      final int size = ((List<Boolean>)Conversions.doWrapArray(this.data)).size();
      final int currIndex = this.index;
      final int newIndex = ((currIndex + 1) % size);
      final boolean oldValue = this.data[currIndex];
      ErrorRateStatistics _xifexpression = null;
      if ((oldValue == newValue)) {
        _xifexpression = new ErrorRateStatistics(this.errors, newIndex, this.data);
      } else {
        ErrorRateStatistics _xblockexpression_1 = null;
        {
          final boolean[] newData = this.data.clone();
          newData[currIndex] = newValue;
          int _xifexpression_1 = (int) 0;
          if (newValue) {
            _xifexpression_1 = (this.errors - 1);
          } else {
            _xifexpression_1 = (this.errors + 1);
          }
          final int newErrors = _xifexpression_1;
          _xblockexpression_1 = new ErrorRateStatistics(newErrors, newIndex, newData);
        }
        _xifexpression = _xblockexpression_1;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  /**
   * Count of errors in the last N operations.
   */
  public int errors() {
    return this.errors;
  }
}
