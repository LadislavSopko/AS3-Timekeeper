package fm.anny.utils
{

// --------------------------------------------------------------------------------------
// 																																			TimekeeperEvent

	import flash.events.Event;

	public class TimekeeperEvent extends Event
	{

// --------------------------------------------------------------------------------------
// 																																		 Fixed properties

		// Event types.
		public static const

			TICK:String = "tick";

		// Values.
		private var

			time:Number;

// --------------------------------------------------------------------------------------
// 																															 Constructor/destructor

		public function TimekeeperEvent( eventType:String, newTime:Number ):void
		{
			super( eventType, true );
			time = newTime;
		}

		public override function clone():Event
		{
			return new TimekeeperEvent( type, time );
		}

	// End of class.
	}
// End of package.
}
