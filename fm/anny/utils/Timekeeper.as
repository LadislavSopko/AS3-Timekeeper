package fm.anny.utils
{

// --------------------------------------------------------------------------------------
// 																																					 Timekeeper

	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.utils.Timer;

	import fm.anny.utils.TimekeeperEvent;

	public class Timekeeper extends EventDispatcher
	{

// --------------------------------------------------------------------------------------
// 																									Values required for proper function

		// Functional preferences.
		private var

			internalFrequency :int =	 5, // Frequency of internal clock in ms.
			tickFrequency		 :int = 100; // Frequency of ticks in ms.

		// Functional values.
		private var

			unixTime	:Number; // Current unix time at constructor and after each call.

		// Functional properties.
		private var

			regulator			:Timer, // Internal timekeeper.
			regulatorAcc	 :int,	 // Inconsistency in ms accumulated since last tick.
			regulatorCache :int;	 // Value of getTimer() at last click.

// --------------------------------------------------------------------------------------
// 																															 Constructor/destructor

		public function Timekeeper( ... tickFreq:Array ):void
		{
			// Initialise values.
			setRealTimeValue();

			// If tickFreq is given, use it as tickFrequency.
			if( tickFreq.length &gt; 0 )
			{
				useMilliseconds( tickFreq[ 0 ]);
			}

			// Set timer so that any premature calls to stop() don't cause runtime errors.
			regulator = new Timer( tickFrequency );
		}

		public function destroy():void
		{
			// Stop timer.
			stop();
		}

// --------------------------------------------------------------------------------------
// 																																	 Set tick frequency

		// Set tick frequency as standard millisecond rate.
		public function useMilliseconds( msFreq:int ):void
		{
			tickFrequency = msFreq;
		}

		// Set tick frequency based on a seconds value.
		public function useSeconds( sFreq:Number ):void
		{
			tickFrequency = sFreq * 1000;
		}

		// Set tick frequency based on a BPM.
		public function useBPM( bpm:int, ... notesPerBeat:Array ):void
		{
			// This will by default tick per beat...
			var calc:Number = 1000 * ( 60/bpm );

			// ... but providing notesPerBeat will enable ticking on smaller notes.
			if( notesPerBeat.length &gt; 0 )
			{
				calc /= notesPerBeat[ 0 ];
			}

			tickFrequency = calc;
		}

// --------------------------------------------------------------------------------------
// 																				 Init, timekeeper info and dispatch functions

		// Set unixTime.
		private function setRealTimeValue():void
		{
			var d:Date = new Date();
			unixTime = d.getTime();
		}

		// Return information, in an object, about the timekeeper.
		public function info():Object
		{
			return { currentTick: unixTime, lastTick: regulatorCache, idealTickFrequency: tickFrequency, actualTickFrequency: regulatorAcc };
		}

		// Dispatch tick event.
		private function tick( newTime:Number ):void
		{
			// Update local unixTime.
			unixTime = newTime;

			// Dispatch event.
			var t:TimekeeperEvent = new TimekeeperEvent( TimekeeperEvent.TICK, newTime );
			dispatchEvent( t );
		}

// --------------------------------------------------------------------------------------
// 																																Timekeeping functions

		// Begin timekeeping.
		public function start():void
		{
			regulatorAcc	 = 0;
			regulatorCache = getTimer();

			regulator = new Timer( internalFrequency );
			regulator.addEventListener( TimerEvent.TIMER, onTimerEvent );

			regulator.start();
		}

		// Stop timekeeping.
		public function stop():void
		{
			if( regulator.running )
			{
				regulator.stop();
			}
		}

		private function onTimerEvent( t:TimerEvent ):void
		{
			// Get new system timer value and contrast with that stored in the cache.
			var regulatorNew	 :int = getTimer();
			var regulatorDelta :int = regulatorNew - regulatorCache;

			// Modify accumulator.
			regulatorAcc += regulatorDelta;

			// Check for a tick.
			if( regulatorAcc &gt; tickFrequency )
			{
				// Dispatch tick event.
				tick( unixTime + tickFrequency );

				// Reset accumulator.
				regulatorAcc -= tickFrequency;
			}

			// Cache regulator value for next call.
			regulatorCache = regulatorNew;
		}

	// End of class.
	}

// End of package.
}
