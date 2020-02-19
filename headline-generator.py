import argparse
import generate_thumb

def gft(args): generate_thumb.generate_friendly_thumb(args.path)

def gt(args): generate_thumb.generate_thumb(args.path, args.position_in_ms)


parser= argparse.ArgumentParser()
group = parser.add_mutually_exclusive_group()
group.add_argument("-v", "--verbose", help="increase output verbosity", action="store_true", default=0)
group.add_argument("-q", "--quiet", help="reduce output verbosity", action="store_true", default=0)
parser.add_argument("-t", "--theme", help="Set a theme to use when generate a headline", choices=["DEFAULT", "AUSTIN"], default="DEFAULT")


subparsers=parser.add_subparsers()
parser_generate_friendly_thumb=subparsers.add_parser("generate_friendly_thumb", aliases=['gft'], help= 'Generate Friendly Thumb')
parser_generate_friendly_thumb.add_argument('path', help='Path video to generate friendly thumb')
parser_generate_friendly_thumb.set_defaults(func=gft)
parser_generate_thumb=subparsers.add_parser("generate_thumb", aliases=['gt'], help= 'Generate Thumb not available yet.')
parser_generate_thumb.add_argument('path', help='Path video to generate friendly thumb')
parser_generate_thumb.add_argument('position_in_ms', type=int, help='Position in ms to generate thumb')
parser_generate_thumb.set_defaults(func=gt)
args=parser.parse_args()
if args.verbose:
  print(">> Verbosity: Using Verbose mode")
elif args.quiet:
  print(">> Verbosity: Quiet mode")  
else:  
  print(">> Verbosity: Normal mode")
args.func(args)

