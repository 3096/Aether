#include "List.hpp"
#include "Utils.hpp"

// Same as Scrollable.hpp
#define PADDING 40

namespace Aether {
    List::List(int x, int y, int w, int h) : Scrollable(x, y, w, h) {
        this->setShowScrollBar(true);
        this->setCatchup(13.5);
        this->heldButton = Button::NO_BUTTON;
    }

    bool List::handleEvent(InputEvent * e) {
        // Store result of event
        bool res = Container::handleEvent(e);

        if ((e->button() == Button::DPAD_DOWN || e->button() == Button::DPAD_UP) && !res && e->id() != FAKE_ID) {
            if (e->type() == EventType::ButtonPressed) {
                this->heldButton = e->button();
                return true;
            }

            if (e->type() == EventType::ButtonReleased && e->button() == this->heldButton) {
                this->heldButton = Button::NO_BUTTON;
                return true;
            }
        }

        return res;
    }

    void List::update(uint32_t dt) {
        // Update children (but not through scrollable!)
        Container::update(dt);

        // Loop over items and adjust position if selected item is not in the middle
        if (this->heldButton == Button::DPAD_DOWN) {
            this->setScrollPos(this->scrollPos + (250 * (dt/1000.0)));
            return;
        } else if (this->heldButton == Button::DPAD_UP) {
            this->setScrollPos(this->scrollPos - (250 * (dt/1000.0)));
            return;
        }

        // If focussed element is not completely inside list scroll to it
        if (this->focussed != nullptr) {
            // Check if above
            if (this->focussed->y() < this->y() + PADDING) {
                this->setScrollPos(this->scrollPos + (this->scrollCatchup * (this->focussed->y() - (this->y() + PADDING)) * (dt/1000.0)));

            // And below ;)
            } else if (this->focussed->y() + this->focussed->h() > this->y() + this->h() - (PADDING*2)) {
                this->setScrollPos(this->scrollPos - (this->scrollCatchup * ((this->y() + this->h() - (PADDING*2)) - (this->focussed->y() + this->focussed->h())) * (dt/1000.0)));
            }
        }
    };
};