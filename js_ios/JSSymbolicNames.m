#if DEBUG

#import "JSBase.h"
#import "JSRandom.h"
#import "JSSymbolicNames.h"

static const char * threeLetterWords = //
"ace act add ado adz aft age ago aha aid ail aim air ale all "//
"amp amy and ann ant any ape apt arc are ark arm art ash ask asp "//
"ass ate atm auk ava ave awe awl axe aye "//
"bad bag bah bam ban bar bat bay bea bed bee beg bet bib bid "//
"big bin bio bit biz boa bob bod bog bon boo bop bot bow box boy "//
"bra bub bud bug bum bun bus but buy bye "//
"cab cad cal cam can cap car cat caw cay cel cob cod cog con coo "//
"cop cot cow coy cry cub cud cue cup cur cut "//
"dab dad dam dap day deb den dew did die dig dim din dip doc doe "//
"dog don dop dot dow dry dub dud due dug duh dun duo dye "//
"ear eat ebb eel egg ego eke elf elk ell elm els emu end eon era "//
"ere erg err etc eve ewe eye "//
"fad fan far fat fax fay fed fee fem fen few fez fib fie fig fin "//
"fir fit fix flu fly fob foe fog fop for fox fro fry fun fur "//
"gab gad gag gal gam gap gar gas gat gay gee gel gem get gig gin "//
"gnu gob god goo got gum gun gus gut guy gym "//
"hag hah ham has hat haw hay heh hem hen her hew hex hey hid "//
"hie him hip his hit hmm hob hod hoe hog hop hot how hoy hub hue "//
"hug huh hum hut "//
"ice icy ida ilk ill imp ink inn ion ire irk ism its ivy "//
"jab jag jam jar jaw jay jet jew jib jig job joe jog jot joy jug "//
"jut "//
"kat kay keg ken key kid kin kip kit koi "//
"lab lad lag lam lap law lax lay led lee leg lei let lib lid lie "//
"lil lip lit lob log lop lot lou low lox lug lux lye "//
"mac mad man map mar mat maw max may men met mew mid mix mob mod "//
"mom moo mop mow mrs mud mug mum "//
"nab nag nah nan nap nay ned net new nib nil nip nit nix nob nod "//
"non nor not now nth  "//
"oaf oak oar oat odd ode off oft ohm oil old ole one ooh opt ore "//
"our out ova owe owl own "//
"pad pal pam pan pap par pat paw pax pay pea peg pen pep per "//
"pet pew pic pie pig pin pip pit pix ply pod poi pop pot pow pox "//
"pro pry pub pug pun pup pus put "//
"rad rag rah ram ran rap rat raw ray red ref rep rex rib rid rig "//
"rim rip rob rod roe rom ron rot row rub rue rug rum run rut rye "//
"sad sag sak sal sam san sap sat saw sax say sea see set sew sex "//
"she shh shy sin sip sir sis sit six ska ski sky sly sob sod sol "//
"son sop sot sow sox soy spa spy sty sub sue sum sun sup "//
"tab tad tag tam tan tap tar tat taw tax tea ted tee ten the tho "//
"thy tic tie til tin tip tis tit toe tog tom ton too top tot tow "//
"toy try tsk tub tug tut tux two "//
"ugh ump urn use "//
"van vat veg vet vex via vie vim vow vox "//
"wad wag wan war was wax way web wed wee wet who why wig win wit "//
"wiz woe wok won woo wow wry "//
"yah yak yam yap yaw yea yeh yen yep yes yet yew yin yip yon you "//
"yuk yum yup "//
"zag zap zen zig zip zit zoe zoo "//
;


#define SETS 26

static NSArray *prefixLists;

@interface JSSymbolicNames ()
{
  int _counts[SETS];
}

@property (nonatomic, assign) int nextSlot;
@property (nonatomic, strong) NSMutableDictionary *ptrNames;

@end


@implementation JSSymbolicNames

+ (void)_constructPrefixList {
  NSMutableSet *set = [NSMutableSet set];
  NSMutableArray *symbolLists = [NSMutableArray array];
  for (int i = 0; i < SETS; i++) {
    [symbolLists addObject:[NSMutableArray array]];
  }
  
  int j = 0;
  char work[10];
  for (int i = 0;; i++) {
    char c = threeLetterWords[i];
    if (!c) break;
    c = _toupper(c);
    if (c == ' ') {
      if (j) {
        work[j] = 0;
        [set addObject:[NSString stringWithUTF8String:work]];
        j = 0;
      }
    } else {
      work[j++] = c;
    }
  }
  
  for (NSString *w in set) {
    const char *w2 = [w UTF8String];
    int sl = w2[0] - 'A';
    [symbolLists[sl] addObject:w];
  }
  
  JSRandom *r = [JSRandom randomWithSeed:1967];
  
  for (int i = 0; i < SETS; i++) {
    NSMutableArray *array = symbolLists[i];
    for (int j = 0; j  < [array count]; j++) {
      int k = [r randomInt:[array count]];
      [array exchangeObjectAtIndex:k withObjectAtIndex:j];
    }
  }
  prefixLists = symbolLists;
}

+ (NSArray *)prefixList {
  ONCE_ONLY(^{[self _constructPrefixList];});
  return prefixLists;
}

- (instancetype)init {
  if (self = [super init]) {
    _ptrNames = [NSMutableDictionary dictionary];
    [self reset];
  }
  return self;
}

- (void)reset {
  @synchronized(self) {
    [_ptrNames removeAllObjects];
    memset(_counts,0,sizeof(_counts));
    _nextSlot = 0;
  }
}

- (NSString *)nameForId:(id)object {
  return [self nameFor:(__bridge void *)object];
}

- (NSString *)nameFor:(const void *)ptr {
  
  if (!ptr) return @"null";
  
  NSNumber *num = [NSNumber numberWithLongLong:(long long)ptr];
  
  NSString *sym;
  
  @synchronized(self) {
    sym = [_ptrNames objectForKey:num];
    
    if (!sym) {
			while (true) {
				int slot = _nextSlot;
				_nextSlot = (_nextSlot + 1) % SETS;
        NSArray *a = [[self class] prefixList][slot];
				if (![a count])
					continue;
        
				int c = _counts[slot]++;
        
				int div = c / [a count];
				int mod = c % [a count];
        
        NSString *divs = @"";
				if (div) {
          divs = [NSString stringWithFormat:@"%d",div];
        }
        sym = [NSString stringWithFormat:@"%@%@",a[mod],divs];
        break;
			}
      [_ptrNames setObject:sym forKey:num];
    }
  }
	return sym;
}

@end

#endif
