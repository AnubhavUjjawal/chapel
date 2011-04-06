/*  This test shows how to use Chapel's task parallelism and locality
 *  features to create a parallel "Hello, world" program that utilizes
 *  multiple distributed memory locales (nodes) and multiple cores
 *  within each locale.
 */


//
// specify whether or not the locale name should be printed (for
// ease-of-testing purposes); default can be overridden on the
// execution command line (e.g., --printLocaleName==false)
//
config const printLocaleName = true;


//
// specify the number of tasks to use per locale; can be overridden
// on the execution command line (e.g. --tasksPerLocale=4)
//
config const tasksPerLocale = 1;

//
// Create a distinct task per locale that we're executing on, as
// specified by the execution-time -nl <numLocales> flag.  This is
// done using the 'coforall' loop structure which creates a task per
// iteration of its loop.  In this case we're iterating over the
// built-in 'Locales' array that stores the array of locale values
// corresponding to the machine resources on which this program is
// running.  Thus, each iteration corresponds to one of the locale
// values, stored in the loop index variable 'loc'.
//
coforall loc in Locales {

  //
  // Migrate the task to the locale in question.  This is done using
  // the 'on' clause that moves execution of the current task to the
  // locale corresponding to the expression that follows it (which can
  // either be a locale value or a variable stored in a particular
  // locale's memory).
  //
  on loc {


    //
    // Now create a number of tasks as specified by the tasksPerLocale
    // configuration constant, again using a coforall loop.  This time
    // we're iterating over a range, so the loop iteration variable
    // 'tid' will store a unique integer in the range
    // 0..tasksPerLocale-1.  Since this loop body doesn't contain any
    // 'on' clauses, all tasks will remain local to the current locale
    // by default.
    //
    coforall tid in 0..#tasksPerLocale {

      //
      // Start creating the message
      //
      var message = "Hello, world! (from ";

      //
      // If we're running more than one task per locale, specialize
      // the message according to the task ID.
      //
      if (tasksPerLocale > 1) then
        message += "task " + tid + " of " + tasksPerLocale + " on ";

      //
      // Specialize the message based on the locale we're running on:
      // - 'here' refers to the locale on which this task is running
      //   (identical to 'loc' above as it turns out)
      // - '.id' queries its unique ID in 0..numLocales-1
      // - '.name' queries its name (similar to UNIX `hostname`)
      // - 'numLocales' refers to the number of locales (as specified by -nl)
      //
      message += "locale " + here.id + " of " + numLocales;
      if (printLocaleName) then message += " named " + loc.name;

      //
      // Terminate the message
      //
      message += ")";

      //
      // Print out the message.  Messages may come out in an arbitrary
      // order due to the use of task parallelism via the coforall
      // loops.  However, the writeln() procedure will prevent
      // messages from getting spliced together due to fine-grain
      // I/O races.
      //
      writeln(message);
    }
  }
}
