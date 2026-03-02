#import "MWMViewController.h"

#include <string>

namespace osm {
class EditableMapObject;
} // namespace osm

@protocol MWMObjectsCategorySelectorDelegate <NSObject>

- (void)reloadObject:(osm::EditableMapObject const &)object;
- (void)didSelectCategory:(std::string const &)category;

@end

@interface MWMObjectsCategorySelectorController : MWMViewController

@property(weak, nonatomic) id<MWMObjectsCategorySelectorDelegate> delegate;
@property(nonatomic) BOOL isCreating;

- (void)setSelectedCategory:(std::string const &)type;

@end
